from threading import Thread, Lock
from datetime import datetime
import logging

from thrift.transport import TTransport
from thrift.transport import TSocket
from thrift.transport import THttpClient
from thrift.protocol import TCompactProtocol
from linethrift import Line
from linethrift.ttypes import *


logger = logging.getLogger('LineClient')


class LineException(Exception):
    pass


class LineMessage:
    """Wraps an underlying message and provides additional operations."""

    TYPE_TEXT = 0
    TYPE_IMAGE = 1

    def __init__(self, client, message):
        self._client = client
        self._type = message.contentType
        self._text = message.text
        self._id = message.id
        self._contentPreview = message.contentPreview
        self._sender = message.frm
        self._recipient = message.to
        self._sendTime = datetime.fromtimestamp(
            message.createdTime / 1000)  # local time

    @property
    def type(self):
        return self._type

    @property
    def id(self):
        return self._id

    @property
    def sender(self):
        return self._client.mid_to_contact(self._sender)

    @property
    def recipient(self):
        return self._client.mid_to_contact(self._recipient)

    @property
    def text(self):
        return self._text

    @property
    def send_time(self):
        return self._sendTime

    @property
    def image_preview(self):
        """Returns raw image data (always JPEG, most likely) for the attached image."""
        if self._type != LineMessage.TYPE_IMAGE:
            raise LineException("This message type does not contain images.")

        return self._contentPreview

    def mark_read(self):
        """Marks this message as read."""
        pass  # TODO: implement

    def __str__(self):
        return '<LineMessage (type={}) "{}", sender={}, recipient={}>'.format(
            self._type, self._text, self._sender, self._recipient)

    __repr__ = __str__


class LineConversation:
    """
    Thread-safe wrapper class that contains a collection of LineMessage objects.

    Updated in real-time by LineClient.
    """

    def __init__(self, client, group):
        self._client = client
        self._messages = []
        self._group = group
        self._lock = Lock()  # mutex for accessing _messages

    @property
    def group(self):
        return self._group

    def last_messages(self, n=-1):
        """
        Returns the most recent n messages already stored locally, with 
        the most recent one first.

        If n <= 0, returns all messages.
        """
        with self._lock:
            if n <= 0:
                return self._messages[:]
            else:
                return self._messages[:n]

    def update(self, n):
        """
        Discards the currently saved messages, downloads the 
        most recent n messages.

        Does not return anything.
        """
        self._client.update_conversation(self._group, n)

    def send_message(self, text):
        """
        Sends a textual message to this conversation, regardless of what type
        of conversation this is (e.g. group chat or individual).
        """
        msg = Line.Message(to=self._group, text=text)
        self._client._send_message(self._group, msg)


class LineContact:
    """Wraps an underlying contact and provides additional operations."""

    def __init__(self, client, contact):
        self._client = client
        self._contact = contact
        self._mid = contact.mid
        self._displayName = contact.displayName
        self._statusMessage = contact.statusMessage
        self._picTmpPath = None  # temporary file path for profile picture

    @property
    def mid(self):
        return self._mid

    @property
    def display_name(self):
        return self._displayName

    @property
    def status_message(self):
        return self._statusMessage

    def send_message(self, text):
        msg = Line.Message(to=self._mid, text=text)
        self._client._send_message(msg)

    def fetch_picture(self):
        """
        Returns a local tmp file path for the profile picture, or None if
        there is no profile picture.

        Lazily retrieved the first time this is called.
        """
        if self._picTmpPath is None:
            pass  # TODO: fetch it via the client

        return self._picTmpPath

    def __str__(self):
        return '<LineContact "{}" ({})>'.format(self._displayName, self._mid)

    __repr__ = __str__


class LineClient:
    """
    Client for LINE using Thrift library.

    Protocol reverse engineering and Thrift interface file thanks 
    to Matti Virkkunen: https://github.com/mvirkkunen/purple-line .

    Methods called are ran on main thread, and a polling loop is run on an
    auxiliary thread.
    """

    DEFAULT_INITIAL_HISTORY = 15

    def __init__(self, email, password):
        self._s4trans, self._s4 = self._getclient("/S4")
        self._p4trans, self._p4 = self._getclient("/P4")

        self._conversations = {}
        self._convmutex = Lock()

        self._login(email, password)

        try:
            self._rev = self._s4.getLastOpRevision()
            self._mid_to_contacts = None
            self.update_contacts()
            self._profile = self._s4.getProfile()
        except TalkException as e:
            if e.code == 8:
                raise LineException("User logged in on another machine.")
            else:
                raise LineException("Error (code %d) %s" % (e.code, e.reason))

                #self.background_thread = Thread(target=self.long_poll, args=())
                #self.background_thread.daemon = True
                #self.background_thread.start()

    EVENT_NEW_MESSAGE = 0

    def long_poll(self):
        """
        Must be called on a new thread shortly after constructing the
        LineClient. Should be called in a loop; new events/messages are
        yielded from this method.

        Yields a sequence of conversation changes, each a tuple of the form
            (type, arg1, arg2).
        For type one of LineClient.EVENT_*, and arg1 and arg2 depending on
        the type.

        For a new message event, arg1 is the LineConversation, and arg2 is
        the LineMessage. So far, no other events are implemented.
        """
        OT = Line.OperationType
        p4 = self._p4

        logger.debug('began long-polling call')
        try:
            ops = p4.fetchOperations(self._rev, 50)
        except EOFError:
            # long-poll timeout
            return
        except TalkException as e:
            if e.code == 8:
                raise LineException("User logged in on another machine.")
            else:
                return

        for op in ops:
            logger.debug('received operation (type %d, name %s)',
                         op.type,
                         OT._VALUES_TO_NAMES.get(op.type, "<unknown>"))

            if op.type == OT.END_OF_OPERATION:
                logger.debug(
                    'processed operation sequence of length %d from long-poll',
                    len(ops))
            elif op.type == OT.SEND_MESSAGE:
                # message sent
                conv, message = self._add_to_conversation(op.message.to,
                                                          op.message)
                yield (LineClient.EVENT_NEW_MESSAGE,
                       conv, message)
            elif op.type == OT.RECEIVE_MESSAGE:
                # message received
                conv, message = self._add_to_conversation(op.message.frm,
                                                          op.message)
                yield (LineClient.EVENT_NEW_MESSAGE,
                       conv, message)
            elif op.type == OT.RECEIVE_MESSAGE_RECEIPT:
                # TODO: handle this
                logger.debug('unhandled: received a read receipt: %s',
                             repr(op))
            else:
                logger.debug(
                    'unhandled/unknown operation (type %d, name %s): %s',
                    op.type,
                    OT._VALUES_TO_NAMES.get(op.type, "<unknown>"),
                    repr(op))

            self._rev = max(op.revision, self._rev)

    _LINE_APP_ID = 'DESKTOPWIN\t3.2.1.83\tWINDOWS\t5.1.2600-XP-x64'

    def _getclient(self, path):
        HOST = "gd2.line.naver.jp"
        PORT = 443
        uri = "https://{}:{}{}".format(HOST, PORT, path)

        transport = THttpClient.THttpClient(uri)
        transport.setCustomHeaders(
            {
                'X-Line-Application': LineClient._LINE_APP_ID,
                'X-Line-Access': 'x'})

        protocol = TCompactProtocol.TCompactProtocol(transport)
        client = Line.Client(protocol)
        transport.open()

        logger.debug(
            "constructed THttpClient transport for uri '%s'; with TCompactProtocol; opened transport",
            uri)
        return transport, client

    def _login(self, email, password):
        result = self._s4.loginWithIdentityCredentialForCertificate(
            email,
            password,
            True,
            '127.0.0.1',
            'pytest',
            Line.Provider.LINE,
            '')
        logger.debug(
            "performed loginWithIdentityCredentialForCertificate; result = %s",
            str(result))

        if result.type == 3:
            raise LineException("PIN required for login; not implemented.")
        elif result.type != 1:
            raise LineException(
                "Login returned error code {}".format(result.type))

        for transport in (self._s4trans, self._p4trans):
            transport.setCustomHeaders({
                'X-Line-Application': LineClient._LINE_APP_ID,
                'X-Line-Access': result.authToken})

    def find_contact(self, name):
        return [contact for contact in self._mid_to_contacts.values() if
                name.lower() in contact.display_name.lower()]

    def update_contacts(self):
        contact_mids = self._s4.getAllContactIds()
        contacts = self._s4.getContacts(contact_mids)
        self._mid_to_contacts = dict(
            [(contact.mid, LineContact(self, contact)) for contact in contacts])
        logger.debug(
            "Updated contacts; now %d contacts excluding user's own profile",
            len(contacts))

        self._profile = self._s4.getProfile()
        self._mid_to_contacts[self._profile.mid] = LineContact(self,
                                                               self._profile)

    @property
    def myself(self):
        """
        Retrieves LineContact corresponding to user's own profile.
        """
        return self._mid_to_contacts[self._profile.mid]

    @property
    def contacts(self):
        return self._mid_to_contacts.values()

    def mid_to_contact(self, mid):
        return self._mid_to_contacts[mid]

    def conversation(self, group):
        """
        Given a group ID or LineContact, retrieve the corresponding LineConversation.
        """
        with self._convmutex:
            if isinstance(group, LineContact):
                group = group.mid
            return self._conversations[group]

    def update_conversation(self, group,
                            initial_history=DEFAULT_INITIAL_HISTORY):
        if isinstance(group, LineContact):
            group = group.mid

        with self._convmutex:
            conv = self._conversations.get(group)
            if conv is None:
                conv = self._conversations[group] = LineConversation(self,
                                                                     group)

            with conv._lock:
                if initial_history > 0:
                    self._conversations[group]._messages = \
                        [LineMessage(self, msg)
                         for msg in
                         self._s4.getRecentMessages(
                             group,
                             initial_history)]
                else:
                    self._conversations[group]._messages = []

    def _add_to_conversation(self, group, message):
        assert isinstance(group, str)

        if not isinstance(message, LineMessage):
            message = LineMessage(self, message)

        with self._convmutex:
            conv = self._conversations.get(group)
            if conv is None:
                conv = LineConversation(self, group)
                with conv._lock:
                    self._conversations[group] = conv
                    self._conversations[group]._messages = \
                        [LineMessage(self, msg) for msg in
                         self._s4.getRecentMessages(group, 20)]
            else:
                with conv._lock:
                    self._conversations[group]._messages.insert(0, message)

        return conv, message

    def _send_message(self, group, msg, seq=0):
        # sendMessage returns a Line.Message object
        result = self._s4.sendMessage(seq, msg)
        self._add_to_conversation(group, result)


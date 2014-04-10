// Naver LINE protocol interface file, functions as used by the desktop client.

namespace cpp line

// :%s/.*"\([^"]*\)", \d\+, \(\d\+\).*/\1 = \2;/

enum TalkExceptionCode {
    ILLEGAL_ARGUMENT = 0;
    AUTHENTICATION_FAILED = 1;
    DB_FAILED = 2;
    INVALID_STATE = 3;
    EXCESSIVE_ACCESS = 4;
    NOT_FOUND = 5;
    INVALID_MID = 9;
    NOT_A_MEMBER = 10;
    INVALID_LENGTH = 6;
    NOT_AVAILABLE_USER = 7;
    NOT_AUTHORIZED_DEVICE = 8;
    NOT_AUTHORIZED_SESSION = 14;
    INCOMPATIBLE_APP_VERSION = 11;
    NOT_READY = 12;
    NOT_AVAILABLE_SESSION = 13;
    SYSTEM_ERROR = 15;
    NO_AVAILABLE_VERIFICATION_METHOD = 16;
    NOT_AUTHENTICATED = 17;
    INVALID_IDENTITY_CREDENTIAL = 18;
    NOT_AVAILABLE_IDENTITY_IDENTIFIER = 19;
    INTERNAL_ERROR = 20;
    NO_SUCH_IDENTITY_IDENFIER = 21;
    DEACTIVATED_ACCOUNT_BOUND_TO_THIS_IDENTITY = 22;
    ILLEGAL_IDENTITY_CREDENTIAL = 23;
    UNKNOWN_CHANNEL = 24;
    NO_SUCH_MESSAGE_BOX = 25;
    NOT_AVAILABLE_MESSAGE_BOX = 26;
    CHANNEL_DOES_NOT_MATCH = 27;
    NOT_YOUR_MESSAGE = 28;
    MESSAGE_DEFINED_ERROR = 29;
    USER_CANNOT_ACCEPT_PRESENTS = 30;
    USER_NOT_STICKER_OWNER = 32;
    MAINTENANCE_ERROR = 33;
    ACCOUNT_NOT_MATCHED = 34;
    ABUSE_BLOCK = 35;
    NOT_FRIEND = 36;
    NOT_ALLOWED_CALL = 37;
    BLOCK_FRIEND = 38;
    INCOMPATIBLE_VOIP_VERSION = 39;
    INVALID_SNS_ACCESS_TOKEN = 40;
    EXTERNAL_SERVICE_NOT_AVAILABLE = 41;
    NOT_ALLOWED_ADD_CONTACT = 42;
    NOT_CERTIFICATED = 43;
    NOT_ALLOWED_SECONDARY_DEVICE = 44;
    INVALID_PIN_CODE = 45;
    NOT_FOUND_IDENTITY_CREDENTIAL = 46;
    EXCEED_FILE_MAX_SIZE = 47;
    EXCEED_DAILY_QUOTA = 48;
    NOT_SUPPORT_SEND_FILE = 49;
    MUST_UPGRADE = 50;
    NOT_AVAILABLE_PIN_CODE_SESSION = 51;
}

exception TalkException {
    1: TalkExceptionCode code;
    2: string reason;
    3: map<string, string> parameterMap;
}

struct Location {
    1: string title;
    2: string address;
    3: double latitude;
    4: double longitude
    5: string phone;
}

enum ToType {
    USER = 0;
    ROOM = 1;
    GROUP = 2;
}

enum ContentType {
    NONE = 0;
    IMAGE = 1;
    VIDEO = 2;
    AUDIO = 3;
    HTML = 4;
    PDF = 5;
    CALL = 6;
    STICKER = 7;
    PRESENCE = 8;
    GIFT = 9;
    GROUBOARD = 10;
    APPLINK = 11;
}

struct Message {
    1: string frm;
    2: string to;
    3: ToType toType;
    4: string id;
    5: i64 createdTime;
    6: i64 deliveredTime;
    10: string text;
    11: optional Location location;
    14: bool hasContent;
    15: ContentType contentType;
    17: string contentPreview;
    18: optional map<string, string> contentMetadata;
}

enum OperationType {
    END_OF_OPERATION = 0;
    UPDATE_PROFILE = 1;
    UPDATE_SETTINGS = 36;
    NOTIFIED_UPDATE_PROFILE = 2;
    REGISTER_USERID = 3;
    ADD_CONTACT = 4;
    NOTIFIED_ADD_CONTACT = 5;
    BLOCK_CONTACT = 6;
    UNBLOCK_CONTACT = 7;
    NOTIFIED_RECOMMEND_CONTACT = 8;
    CREATE_GROUP = 9;
    UPDATE_GROUP = 10;
    NOTIFIED_UPDATE_GROUP = 11;
    INVITE_INTO_GROUP = 12;
    NOTIFIED_INVITE_INTO_GROUP = 13;
    CANCEL_INVITATION_GROUP = 31;
    NOTIFIED_CANCEL_INVITATION_GROUP = 32;
    LEAVE_GROUP = 14;
    NOTIFIED_LEAVE_GROUP = 15;
    ACCEPT_GROUP_INVITATION = 16;
    NOTIFIED_ACCEPT_GROUP_INVITATION = 17;
    REJECT_GROUP_INVITATION = 34;
    NOTIFIED_REJECT_GROUP_INVITATION = 35;
    KICKOUT_FROM_GROUP = 18;
    NOTIFIED_KICKOUT_FROM_GROUP = 19;
    CREATE_ROOM = 20;
    INVITE_INTO_ROOM = 21;
    NOTIFIED_INVITE_INTO_ROOM = 22;
    LEAVE_ROOM = 23;
    NOTIFIED_LEAVE_ROOM = 24;
    SEND_MESSAGE = 25;
    RECEIVE_MESSAGE = 26;
    SEND_MESSAGE_RECEIPT = 27;
    RECEIVE_MESSAGE_RECEIPT = 28;
    SEND_CONTENT_RECEIPT = 29;
    SEND_CHAT_CHECKED = 40;
    SEND_CHAT_REMOVED = 41;
    RECEIVE_ANNOUNCEMENT = 30;
    INVITE_VIA_EMAIL = 38;
    NOTIFIED_REGISTER_USER = 37;
    NOTIFIED_UNREGISTER_USER = 33;
    NOTIFIED_REQUEST_RECOVERY = 39;
    NOTIFIED_FORCE_SYNC = 42;
    SEND_CONTENT = 43;
    SEND_MESSAGE_MYHOME = 44;
    NOTIFIED_UPDATE_CONTENT_PREVIEW = 45;
    REMOVE_ALL_MESSAGES = 46;
    NOTIFIED_UPDATE_PURCHASES = 47;
    DUMMY = 48;
    UPDATE_CONTACT = 49;
    NOTIFIED_RECEIVED_CALL = 50;
    CANCEL_CALL = 51;
    NOTIFIED_REDIRECT = 52;
    NOTIFIED_CHANNEL_SYNC = 53;
    FAILED_SEND_MESSAGE = 54;
    NOTIFIED_READ_MESSAGE = 55;
    FAILED_EMAIL_CONFIRMATION = 56;
    NOTIFIED_PUSH_NOTICENTER_ITEM = 59;
    NOTIFIED_CHAT_CONTENT = 58;
}

enum OperationStatus {
    NORMAL = 1;
    ALERT_DISABLED = 1;
}

struct Operation {
    1: i64 revision;
    2: i64 createdTime;
    3: OperationType type;
    4: i32 reqSeq;
    5: string checkSum;
    7: OperationStatus status;
    10: string param1;
    11: string param2;
    12: string param3;
    20: Message message;
}

// ew.class
enum Provider {
    UNKNOWN = 0;
    LINE = 1;
    NAVER_KR = 2;
}

struct LoginResult {
    1: string authToken;
    // 2: certificate;
    // 3: verifier;
    // 4: pinCode;
    5: i32 type;
}

struct Profile {
    1: string mid;
    3: string userid;
    10: string phone;
    11: string email;
    12: string regionCode;
    20: string displayName;
    21: string phoneticName;
    22: string pictureStatus;
    //23: string thumbnailUrl_; // Old field.
    24: string statusMessage;
    31: bool allowSearchByUserid;
    32: bool allowSearchByEmail;
    33: string picturePath;
}

enum ContactType {
    MID = 0;
    PHONE = 1;
    EMAIL = 2;
    USERID = 3;
    PROXIMITY = 4;
    GROUP = 5;
    USER = 6;
    QRCODE = 7;
    PROMOTION_BOT = 8;
}

enum ContactStatus {
    UNSPECIFIED = 0;
    FRIEND = 1;
    FRIEND_BLOCKED = 2;
    RECOMMEND = 3;
    RECOMMEND_BLOCKED = 4;
    DELETED = 5;
    DELETED_BLOCKED = 6;
}

enum ContactRelation {
    ONEWAY = 0;
    BOTH = 1;
    NOT_REGISTERED = 2;
}

// Name guessed.
enum ContactSettingsFlags {
    CONTACT_SETTING_NOTIFICATION_DISABLE = 1;
    CONTACT_SETTING_DISPLAY_NAME_OVERRIDE = 2;
    CONTACT_SETTING_CONTACT_HIDE = 4;
    CONTACT_SETTING_FAVORITE = 8;
    CONTACT_SETTING_DELETE = 16;
}

struct Contact {
    1: string mid;
    2: i64 createdTime;
    10: ContactType type;
    11: ContactStatus status;
    21: ContactRelation relation;
    22: string displayName;
    23: string phoneticName;
    24: string pictureStatus;
    25: string thumbnailUrl_; // Old field.
    26: string statusMessage;
    27: string displayNameOverridden;
    28: i64 facoriteTime,
    31: bool capableVoiceCall;
    32: bool capableVideoCall;
    33: bool capableMyhome;
    34: bool capableBuddy;

    // Bitfield. 32 = "official account" (shows green badge icon)
    35: i32 attributes;

    // Bitfield of ContactSettingsFlags
    36: i64 settings;

    37: string picturePath;
}

struct Group {
    1: string id;
    2: i64 createdTime;
    10: string name;
    11: string pictureStatus;
    20: list<Contact> members;
    21: Contact creator;
    22: list<Contact> invitee;
}

struct Room {
    1: string mid;
    2: i64 createdTime;
    10: list<Contact> contacts;
    31: bool notificationDisabled;
}

struct MessageBox {
    1: string id;
    2: string channelId;
    5: i64 lastSeq;
    6: i64 unreadCount;
    7: i64 lastModifiedTime;
    8: i32 status;
    9: ToType midType;
    10: list<Message> lastMessages;
}

// Names guessed
struct MessageBoxEntry {
    1: MessageBox messageBox;
    2: string displayName;
    3: list<Contact> contacts;
    4: string mystery; // looks like Contact::pictureStatus
}

// Names guessed
struct MessageBoxCompactWrapUpList {
    1: list<MessageBoxEntry> entries;
    2: i32 mystery; // seen: 0
}

// cyd.class
service Line {
    // Gets authentication key
    LoginResult loginWithIdentityCredentialForCertificate(
        3: string identifier,
        4: string password,
        5: bool keepLoggedIn,
        6: string accessLocation,
        7: string systemName,
        8: Provider identityProvider,
        9: string certificate) throws (1: TalkException e);

    // Gets current user's profile
    Profile getProfile() throws (1: TalkException e);

    // Gets list of current user's contact IDs
    list<string> getAllContactIds() throws (1: TalkException e);

    // Gets list of current user's recommended contacts IDs
    list<string> getRecommendationIds() throws (1: TalkException e);

    // Gets detailed information on contacts
    list<Contact> getContacts(2: list<string> ids) throws (1: TalkException e);

    // Gets list of current user's joined groups
    list<string> getGroupIdsJoined() throws (1: TalkException e);

    list<Group> getGroups(2: list<string> ids) throws (1: TalkException e);

    MessageBoxCompactWrapUpList getMessageBoxCompactWrapUpList(2: i32 mystery1, 3: i32 mystery2)
        throws (1: TalkException e);

    // Get recent messages from a group chat (n.b. arg names guessed)
    list<Message> getRecentMessages(2: string gid, 3: i32 count) throws (1: TalkException e);

    // Returns incoming events
    list<Operation> fetchOperations(2: i64 localRev, 3: i32 count) throws (1: TalkException e);

    // Returns current revision ID for use with fetchOperations
    i64 getLastOpRevision() throws (1: TalkException e);

    // Sends a message to chat or user
    Message sendMessage(1: i32 seq, 2: Message message) throws (1: TalkException e);

    Contact findAndAddContactsByMid(1: i32 reqSeq, 2: string mid) throws (1: TalkException e);
}

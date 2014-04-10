===============================
Python LINE client library
===============================

.. image:: https://badge.fury.io/py/python-line.png
    :target: http://badge.fury.io/py/python-line
    
.. image:: https://travis-ci.org/bshillingford/python-line.png?branch=master
        :target: https://travis-ci.org/bshillingford/python-line

.. image:: https://pypip.in/d/python-line/badge.png
        :target: https://crate.io/packages/python-line?version=latest


An unofficial library for NAVER's LINE messenging protocol in Python.

Apache Thrift interface file for LINE protocol thanks to Matti Virkkunen, from
https://github.com/mvirkkunen/purple-line

* Free software: BSD license
* Documentation: http://python-line.rtfd.org.

Features
--------

* Basic IM functionality: send messages to conversations (contacts, group chats, etc.)
* Background thread for long-polling from LINE server (e.g. for messages)
* Minimal sign-in functionality
* Send and receive text messages
* Receive picture messages


Future features and TODOs
-------------------------

* Handling read receipts
* Retrieving profile pictures
* Retrieving full-resolution image attachments
* Retrieving stickers
* Properly handle device authorization for first time sign-in
* Adding/removing/blocking/... contacts
* Enumerate other conversation types



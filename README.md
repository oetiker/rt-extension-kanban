# NAME

RT-Extension-Kanban - Adds a Kanban to 'request tracker' which uses jQuery UI and Websockets for data visualization.

# INSTALLATION

- perl Makefile.PL
- make
- make install (this may need root permissions)
- Edit your /opt/rt4/etc/RT_SiteConfig.pm and add this line:

        Plugin('RT::Extension::KANBAN');

- Clear your mason cache
    ```sh
    rm -rf /opt/rt4/var/mason_data/obj
    ```
- Restart your webserver serving RT

If you want live-updates of the Kanban with multiple clients you might want to install:

*  <https://github.com/nixcloud/rt-coreExtension-websocket>

# CONFIGURATION

## Kanban configuration

The Kanban-View can be configured within the `RT_SiteConfig.pm` of the RT. 
Available options are `KanbanDefault` and `Kanban_USERNAME`.

Both consume a string which should be an JSON object. 

For example the following configuration defines a Kanban that is only available for the user _root_.

```javascript
Set( $Kanban_root, q(
{
  "lanes":[
    {
      "Name": "New Open",
      "Status": ["open", "new"],
      "Query": "(Status='open' OR Status='new')"
    },
    {
      "Name": "Resolved",
      "Status": ["resolved"],
      "Query": "(Status='resolved') AND (LastUpdated > '{{=it.Date}}')"
    }
  ],
  "timeOffSet":7
}));
```  

NOTE: Whenever you make changes to the $Kanban_root or $KanbanDefault configuration **CLEAR THE CACHE**:

- Clear your mason cache
    ```sh
    rm -rf /opt/rt4/var/mason_data/obj/*
    ```

### Lanes
Under _lanes_ every lane within the Kanban is defined. You can easily add or remove custom lanes:

* `name` The Name displayed.
* `Status` The `status` that tickets are allowed to have within this lane. The first set `status` is also the `status` that will be set if a ticket is moved into this lane.
* `Query` The actuall `query` used to get the tickets. Every query that is allowed within the REST 1.0 inteface of RT can be used. 

### Keywords
Currently there are two keywords that are replaced before a query is made:

- `{{=it.Date}}` is replaced with the current date minus `timeOffSet` days. In the above example the `Resolved` lane would only hold tickets that are younger than a week. 
- `{{=it.CurrentUser}}` is replaced with the username of the logged in RT user. This is usefull to build a generic configuration. This is shown in the following example. 

### Example

This example shows a Kanban configuration for a Kanban with 3 lanes: 

* The first lane shows all new and open tickets that are not `taken` or that are owned by the current user. 

* The second lane shows all stalled tickets that are owned by the current user. 

* The Last lane shows all resolved tickets with a maximum age of 2 days that are owned by any user.

```javascript
Set( $KanbanDefault, q(
{
  "lanes":[
    {
      "Name": "New Open",
      "Status": ["open", "new"],
      "Query": "(Status='open' OR Status='new') AND (Owner='Nobody' OR Owner='{{=it.CurrentUser}}')"
    },
    {
      "Name": "Stalled",
      "Status": ["stalled"],
      "Query": "(Status='stalled') AND (Owner='{{=it.CurrentUser}}')"
    },
    {
      "Name": "Resolved",
      "Status": ["resolved"],
      "Query": "(Status='resolved') AND (LastUpdated > '{{=it.Date}}')"
    }
  ],
  "timeOffSet":2
}));
```  


## Kanban WebSocket configuration

By default the WebSocket used by the Kanban-view connects to the same origin which means it will use WSS 
when you are using HTTPS. This will require a reverse-proxy setup that maps 

* '/' to the RT webserver and 
* '/webserver' to the RT::WS webserver.

However, if you don't want to use a reverse-proxy setup, you can set:

    Set( $WebsocketPort , "5000");

With this variable set, you still need to have both webservers on the same domain since rt-coreExtension-websocket 
shares the session cookie with request tracker.

NOTE: Whenever you make changes to the $WebsocketPort setting **CLEAR THE CACHE**:

- Clear your mason cache
    ```sh
    rm -rf /opt/rt4/var/mason_data/obj/*
    ```

# USAGE

## Summary
Once you are subscribed to the WS you will receive updates every time a Ticket in RT is changed.

# AUTHOR

- Paul Seitz <paul.m.seitz@gmail.com>
- Joachim Schiele <js@lastlog.de>

# BUGS

All bugs should be reported to our BUG-tracker at: 

* <https://github.com/nixcloud/rt-extension-kanban>

# LICENSE AND COPYRIGHT

This software is Copyright (c) 2016 by Joachim Schiele/Paul Seitz

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

# NAME

RT-Extension-Kanban - Adds a Kanban to 'request tracker' which uses jQuery UI and Websockets for data visualization and management.

![A screenshot featuring the Kanban view with WebSocket status](https://raw.githubusercontent.com/nixcloud/rt-extension-kanban/master/screenshots/kanban.jpg)

Main features:

* realtime updates on all attached browsers: **No more page reloads** powered by WebSockets
* **drag'n'drop ticket operations**
* **powerful display-filters** which support regular expressions
* **highly configurable** columns and drop-actions 
* **Kanban-fullscreen** support for big monitors

# USAGE
This kanban features all typical kanban functions as moving tickes per drag and drop. Depending where you drop tickets, their state will get updated using `REST 1.0`-calls. In each column the tickets are sorted by priority (highest at the top). The kanban-view is updated if tickets are altered using the `rt-coreExtension-websockets` technique. This means that each view is always up to date without any manual reloading.

The view and its behaviour is completly configurable. You can define Which columns are shown and which ticket attributes they should represent. You can also define how the ticket is altered when it is dropped in a different column.     
On top of that: when a ticket _A_ is dropped above another ticket _B_ the Priority of _A_ will be adjusted to be higher than _B_'s. By default, the tickets priority will never be reduced and only increased by the minimum amount to stay at the dropped possition. 

# INSTALLATION

- perl Makefile.PL
- make
- make install (this may need root permissions)
- Edit your /opt/rt4/etc/RT_SiteConfig.pm and add this line:

        Plugin('RT::Extension::KANBAN');

- Clear your mason cache
    ```sh
    rm -rf /opt/rt4/var/mason_data/obj/*
    ```
- Restart your webserver serving RT

If you want live-updates of the Kanban with multiple clients you might want to install:

*  <https://github.com/nixcloud/rt-coreExtension-websocket>

# CONFIGURATION

## Kanban configuration

NOTE: There is a default configuration and chaning it is optional.

The Kanban-views can be configured within the `RT_SiteConfig.pm` of the RT. 
To do so, the hashmap `%KanbanConfigs` has to be defined.



For example, the following configuration defines a single Kanban that only has two lanes:

```javascript
Set( %KanbanConfigs, (MyFirstKanban => q(
{
  "lanes":[
    {
      "Name": "New Open",
      "Change": {"Status": "open"},
      "Query": "(Status='open' OR Status='new')"
    },
    {
      "Name": "Resolved",
      "Change": {"Status": "resolved"},
      "Query": "(Status='resolved') AND (LastUpdated > '{{=it.Date}}')",
      "timeOffSet":7
    }
  ]
})));
```  

NOTE: Whenever you make changes to the $Kanban_root or $KanbanDefault configuration **CLEAR THE CACHE**:

- Clear your mason cache
    ```sh
    rm -rf /opt/rt4/var/mason_data/obj/*
    ```
Befor you start your instance of RT.

### Lanes
Under _lanes_ every lane within the Kanban is defined. You can easily add or remove custom lanes. A lane is defined by the following object:
```javascript
{
    "Name": XXX,
    "Query": XXX,
    "Change": {YYY: XXX, YYY: XXX},
    "timeOffset": XXX
    "CallOnEnter": XXX
}
```

* `name` The Name displayed.
* `Query` The actuall `query` used to get the tickets. This `query` is limited by some factors:
    * Every field within a ticket can be accessed.
    * Only `queries` that are allowed within the `REST 1.0` inteface of RT can be used. 
    * The query is translated into a javascript function that is used to sort tickets within the javascript context. At the time beeing, this are the only commands that are supported: 
        ```
        AND, OR, NOT, =, <, <=, >, >=, !=, <>
        ```
* `Change` One or more fields of the ticket that should be changed when the ticket is moved into this column. For Example `{"Status": "resolved"}` would change the tickets `Status` to the value `resolved`.    
  NOTE: After the changes the Ticket should match the query. 
* `timeOffset` (_optional_) Time messured in days. This is usfull if you want a query using the Date. Within any `query` the string `{{=it.Date}}` will be replaced with `the current Date - timeOffSet`. On default this value is `5`. 
* `CallOnEnter` (_optional_) A javascript function that is called when a ticket is moved into this column. It has access to the ticket and has to return an array of strings. Each string should be the name of an field that has to be updated in the remote DataBase. This can be used for complicated setups to inforce that the ticket actually matches the query.


### Keywords
Currently there are two template variables used. These are replaced before a value (for example a query) is evaluated:

- `{{=it.Date}}` is replaced with the current date minus `timeOffSet` days. In the above example the `Resolved` lane would only hold tickets that are less than a week. 
- `{{=it.CurrentUser}}` is replaced with the username of the `logged in` RT user. This can be used to build a generic configuration shown in the following example. 

### Examples

This example shows a Kanban configuration for a Kanban with 3 lanes: 

* The first lane shows all new and open tickets that are not `taken` or that are owned by the current user. 

* The second lane shows all stalled tickets that are owned by the current user. 

* The Last lane shows all resolved tickets with a maximum age of 2 days that are owned by any user.

```javascript
{
  "lanes":[
    {
      "Name": "New Open",
      "Change": {"Status": "open"},
      "Query": "(Status='open' OR Status='new') AND (Owner='Nobody' OR Owner='{{=it.CurrentUser}}')"
    },
    {
      "Name": "Stalled",
      "Change": {"Status": "stalled"},
      "Query": "(Status='stalled') AND (Owner='{{=it.CurrentUser}}')"
    },
    {
      "Name": "Resolved",
      "Change": {"Status": "rejected"},
      "Query": "(Status='resolved') AND (LastUpdated > '{{=it.Date}}')",
      "timeOffSet":2
    }
  ]
}
```  

The following example defines two Kanbans. The first one features a lane `IMPORTANT` that contains only tickets with a Priority that is at least 100. Every ticket that is moved into this lane will get at least a priority of 100. Also whenever a ticket is dropped, the user is informed with 'hello world'. While the `alert('hello world')` can be removed it shows how the interface can be used with javascript code.

The second Kanban features a lane with open/new tickets that have no owner. Also there are two additional lanes for the user `foo` and `bar`. If a ticket is moved into `foo` the owner is changed to `foo`. The same happens with the `bar` lane.

```
Set( %KanbanConfigs, (
important => q(
{
    "lanes":[
    {
      "Name": "New Open",
      "Change": {"Status": "open"},
      "Query": "(Status='open' OR Status='new') AND Priority<100"
    },
    {
      "Name": "IMPORTANT",
      "Change": {"Status": "open"},
      "CallOnEnter": "{
            if (ticket.Priority < 100){
                ticket.Priority = 100;
            }
            alert('hello world');
            return [];
        }",
      "Query": "(Status='open' OR Status='new') AND Priority >=100"
    },
    {
      "Name": "Resolved",
      "Change": {"Status": "resolved"},
      "Query": "(Status='resolved') AND (Resolved > '{{=it.Date}}')",
      "timeOffSet":2
    }
  ]
}),
distributeTickets => q(
{
    "lanes":[
    {
      "Name": "New Open",
      "Change": {"Status": "open"},
      "Query": "(Status='open' OR Status='new') AND (Owner = 'Nobody')"
    },
    {
      "Name": "foo",
      "Change": {"Owner": "foo"},
      "Query": "(Status != 'Resolved' AND Status != 'Rejected' AND Owner = 'foo')"
    },
    {
      "Name": "bar",
      "Change": {"Owner": "bar"},
      "Query": "(Status != 'Resolved' AND Status != 'Rejected' AND Owner = 'bar')"
    }
  ]
})));

```


## Kanban Userspecific configuration
### Limit available Kanbans
Since you can configure multiple Kanbans which might not be usefull for all users. This section shows you how to limit the available Kanban(s) per user.

The Kanbans available to the user can be limited with the options `@KanbanDefault` and `@Kanban_USERNAME`.
  * `@KanbanDefault` needs an Array of KanbanNames. Those are the Kanbans that are available to all users. (Unless a `@Kanban_USERNAME` is defined)
  * `@Kanban_USERNAME` is exactly like `@KanbanDefault` but only workes for a single user. `USERNAME` must be replaced with an existing RT-user for whom this Kanban is configured. 
  * This options can also be used to define the order of the Kanbans shown in the drop down menu.

Example:
```
Set(@Kanban_FooBar, "KanbanNameX", "KanbanNameY");
```

### Read Only
`KanbanReadOnly__USERNAME_` sets a user to read only. This has nothing to do with any RT user setting. If this option is set to `true` it alters the view for tickets in a way that no more userinput is possible (only exception is moving and dropping the ticket).

Example:
```
Set( $KanbanReadOnly_ClientX, 1)
```

### cutCreatorName
`$cutCreatorName` Beware of long creator names as they would lead to a broken Kanban-view. Therfore the creator names are cut after 10 characters. This option can change the number of displayed characters.

Example:
```
Set( $cutCreatorName, 12)
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

# THANKS
* [LiHAS Stuttgart](http://www.lihas.de/) for sponsoring this work
* [Bob Cravens](http://bobcravens.com/) for his kanban example and letting us use it
* Christian Loos <cloos@netcologne.de> for his help with RT
* Shawn Moore <shawn@bestpractical.com> for his help with RT
* Jim Brandt <jbrandt@bestpractical.com> for his help with RT

# LICENSE AND COPYRIGHT

This software is Copyright (c) 2016 by Joachim Schiele/Paul Seitz

This is free software, licensed under:

The GNU General Public License, Version 2, June 1991

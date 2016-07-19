---
aliases: ["/archives/304"]
title: "Javascript scope"
date: "2009-02-26T18:39:08-06:00"
tags: [mitsi, extjs, javascript]
guid: "http://blog.afoolishmanifesto.com/?p=304"
---
One of my least favorite things about javascript is scope management. In most languages scope is quite clear; if you defined a variable previously **and** "higher up" in some kind of scope stack, you can access it. And furthermore, **this** always refers to the current object. That's not quite true for javascript, because javascript is different than (almost) any other programming language you have ever used. You don't like monkeypatching? Bummer. That's how objects are _created_ in javascript...more or less. But more on that later. Right now: **scope**.

Here is a base form that I wrote for work. We use ExtJS for all of our UI, which lets us do cool things like this. Feel free to read it like a story; I just want to point out lines 18-37. Take a look at those and then read on.

    Ext.ns('ACDRI.ui');

    ACDRI.ui.BaseForm = Ext.extend(Ext.FormPanel, {
        generateUrl: function() {
              return '/devcgi/init.plx/controller_' +
                this.controller + '/' + this.action;
        },
        validateRole: function(form, action) {
           console.error(action);
        },
        initComponent: function() {
           var config = {
              bodyStyle:'padding:5px 5px 0',
              width: 350,
              defaults: {width: 230},
              buttons: [{
                 text: 'Save',
                 handler: function() {
                    this.getForm().submit({
                      url: this.url,
                      baseParams: this.baseParams,
                      waitMsg:'Saving...',
                      success:function(form, action){
                         this.closeFunction();
                         console.log(this);
                         if (this.successFunction) {
                            this.successFunction();
                         }
                      },
                      failure:function(form, action){
                         this.validateRole(form,
                             action);
                      },
                      scope: this
                    });
                 },
                 scope: this
              },{
                 scope: this,
                 text: 'Cancel',
                 handler: function() {
                    this.closeFunction();
                 }
              }]
           };
           Ext.apply(this, config);
           ACDRI.ui.BaseForm.superclass.
             initComponent.apply(this, arguments);
        }
     });

Note the "scope: this" directives sprinkled throughout the code. The reason for the usage of the directives is that we have some functions (success, etc) that have the keyword **this** in them. By default **this** is supposed to refer to the object from which the method is called (the invocant), but with a language like javascript where you can add methods and variables to objects (kinda like monkeypatching, but only for instances of objects) on the fly, you start to realize that sometimes you don't want **this** to be the invocant, but something else. You probably want **this** to be the object that adds the method to the other object. Well, in ExtJS the scope config option allows you to set the invocant.

In the above example we have to set the invocant because otherwise the validateRole method will be called from the button, and not the form. The same follows for the this.getForm() etc.

That's pretty common in Ext. People run into this kind of thing all the time because they assume that what they are configuring is the current object but it usually isn't.

But that's chump change to what I had to do below. Read (17-19):

```
Ext.ns('ACDRI.ui');

ACDRI.ui.CustomerContacts = Ext.extend(
  ACDRI.ui.Grid, {
    addFunction: function() {
       var win;
       win = new ACDRI.ui.FormWindow({
           title: 'Create New ' + this.itemName,
           height: 250,
           items: [{
              url: this.generateCreationUrl(),
              baseParams: {
                 customer_id: this.customer_id
              },
              xtype: 'customer_contact_form',
              //  /  Look here  /
              successFunction: function() {
                 this.getStore().load();
              }.createDelegate(this),
              closeFunction: function() {
                 win.close();
              }
           }]
          });
       win.show();
    },
    initComponent: function() {
       this.record = Ext.data.Record.create([
          {name: 'id', type: 'string'},
          {name: 'first_name', type: 'string'},
          {name: 'last_name', type: 'string'},
          {name: 'phone', type: 'string'},
          {name: 'fax', type: 'string'},
          {name: 'email', type: 'string'}
          ]);
       var config = {
          controller: 'WorkOrderEntry',
          action: 'customer_contacts',
          title: 'Contacts',
          itemName: 'Contact',
          baseParams: {
            customer_id: this.customer_id
          },
          columns: [{
             header: 'Name',
             renderer: function(value, metadata,
               record) {
                var t = new Ext.XTemplate([
                  '<tpl if="email">',
                   '<a href="mailto:{email}">',
                   '{first_name} {last_name}</a>',
                  '</tpl>',
                  '<tpl if="!email">',
                   '{first_name} {last_name}',
                  '</tpl>'
                ]);
                return t.applyTemplate({
                  email: record.get('email'),
                  first_name:
                   record.get('first_name'),
                  last_name:
                   record.get('last_name')
                });
             },
             sortable: true,
             width: 110
          },{
             header: 'Phone',
             dataIndex: 'phone',
             sortable: true,
             width: 110
          },{
             header: 'Fax',
             dataIndex: 'fax',
             sortable: true,
             width: 110
          }]
       };
      Ext.apply(this, config);
      ACDRI.ui.CustomerContacts.superclass.
        initComponent.apply(this, arguments);
    }
 });

Ext.reg('customer_contacts',
    ACDRI.ui.CustomerContacts);
```

See, the scope option is Ext specific. When you start doing your own stuff (like I am) you have to deal with scope yourself. createDelegate (bind in Prototype) helps us set the scope in a function. It gives us a new anonymous function with the scope set to whatever we passed it.

The issue above is that we want the window to reload the grid after a successful save. The window doesn't know anything about the grid, so we have to explicitly tell it that the **this** is the grid. That's what createDelegate does.

Crazy huh?

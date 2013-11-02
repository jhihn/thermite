thermite
========

start master node (and 2 internal db nodes for testing/devel)

```sh
node server.js
```

start separate db node (not currently needed):

```sh
node dbnode.js 3001 databases/node1.db
node dbnode.js 3002 databases/node2.db
```

Project Organization
--------------------

* `/db-node` - all files for the database node
* `/master-node` - all files for the master node
    * `/master-node/lib` - the meat and potatoes. all the logic is here.
    * `/master-node/webclient` - all files handed to a web browser (after processing). html, css, images, etc.
    * `/master-node/routes` - maps urls to functions
    * `/master-node/startup.coffee` - starts up the master node, starts a web server, call other moduels to start
* `server.js` - entry point for the master node, just calls `master-node/startup.coffee`

Dependencies
* [async] (https://npmjs.org/package/async): Helps get out of callback-nesting hell
    * [Documentation](https://github.com/caolan/async/blob/master/README.md)
* [underscore](https://npmjs.org/package/underscore): functional programming utilities for java arrays, objects, etc
    * [Documentation](http://underscorejs.org/)

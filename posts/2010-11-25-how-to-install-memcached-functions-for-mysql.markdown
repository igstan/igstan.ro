---------------------------------------------------
title: How to install Memcached functions for MySQL
author: Ionuț G. Stan
date: November 25, 2010
---------------------------------------------------


Download [libmemcached 0.35][1] (any version greater than this won't work) and
[Memcached functions for MySQL][2] (I've used version 1.1).

Extract libmemcached and execute the following inside the extracted directory:

~~~ {.bash}
./configure
make
sudo make install
~~~

Extract the Memcached functions archive and execute the following inside the
extracted directory:

~~~ {.bash}
./configure
make
sudo make install
~~~

Execute the following query inside a MySQL client and copy the returned value:

~~~ {.sqlmysql}
SHOW VARIABLES LIKE 'plugin_dir';
~~~

Copy the compiled Memcached libraries to the MySQL plugins directory:

~~~ {.bash}
sudo cp /usr/local/lib/libmemcached_functions_mysql* <VALUE_FROM_ABOVE_QUERY>
~~~

Restart the MySQL server, then go to Memcached functions dir and then the "sql"
directory. Log into a mysql client in that dir:

~~~ {.bash}
$ mysql -uroot
mysql> source ./install_functions.sql
~~~

You're done. Hopefully.


[1]: https://launchpad.net/libmemcached/+download?start=10
[2]: https://launchpad.net/memcached-udfs/+download

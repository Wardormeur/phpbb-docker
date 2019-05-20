DO NOT USE IN PRODUCTION

Set your path to phpbb directory with 
`cd .. && git clone https://github.com/phpbb/phpbb.git && cd - && ./setup-phpbb-git`

Run `docker-compose down -v && docker-compose build && docker-compose up phpbb`
Admin account is admin:adminadmin 

Run the tests
```
  cd /var/www/html
  # PHPBB tests
  phpBB/vendor/bin/phpunit --debug
  # Ext tests
  export PHPBB_FUNCTIONAL_URL=/phpBB/
  export PHPBB_TEST_CONFIG=phpBB/config.php
  phpBB/vendor/bin/phpunit --debug -c ext/wardormeur/anoncache/phpunit.xml.dist --testsuite functional
```

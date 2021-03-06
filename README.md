simple_ci
=========

Simple CI system

## Installation

Make sure you have all necessary gems installed:

```sh
bundle install
```

Also you need to install [rabbitmq](http://www.rabbitmq.com/download.html).

Then create a database (SQLite would be sufficient for CI with 1-2 project):

```sh
rake db:create db:migrate db:seed
```

After running db:seed task you'll get a user with email 'simple_ci@example.com' and password: 'password. Also there would be a project created (which points to the current project, namely SimpleCI), so you could check how it works.

Run rabbitmq-server from the first terminal window:

```sh
rabbitmq-server
```

Then run from another terminal:

```sh
unicorn_rails
```

And finally run queue worker from yet another terminal:

```sh
rake run_queue
```

## License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

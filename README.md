# Listen-n-Load

Reloading code in-process is hard. Really hard. This is a tiny, error-prone way to do it inside of a REPL like IRB.

Requires:

- Ruby
- [entr](http://www.entrproject.org/)
- nc (netcat; If you're on OSX or a Linux, you probably have it already)

`entr` is a small utility that watches a list of given files for changes. `nc` is a tool for working with TCP sockets.

## Try it Out

To run the demo, load IRB with the hot-reloader and the sample code:

```sh
> irb -r ./listen_n_load.rb ./lib/skeleton.rb
```

In a separate terminal window, pipe a list of files to `entr`:

```sh
find lib/*.rb | entr -p ./reloader.sh /_
```

This is doing the following:

- `find` makes a list of all the files in the `lib` directory with a `*.rb` extension.
- The pipe (`|`) supplies the list to `entr`.
- `entr` begins watching the list for changes. When one changes, it calls the `reloader.sh` script and supplies the name of the changed file as an argument to that script (that variable is denoted by `/_`).

In an editor, you can add a new method to the sample code:

```rb
# lib/skeleton.rb
module Skeleton
  def self.bones
    'them bones, them bones, them dry bones'
  end

  def self.dance!
    '(the skeleton dances)'
  end
end
```

Now, in IRB:

```sh
> Skeleton.dance!
```

Your code was automatically reloaded! Cool, I guess.

## How it Works

The Ruby TCP server is running in a thread inside your console session. We use a thread because otherwise the TCP server would block the console from loading. Inside the thread, it sits in the background and listens on port 2222. When a file changes, `entr` and the shellscript send the name of the file to that TCP port. The server gets the name of the file and executes some code to load it.

This approach has some major drawbacks. For instance, while running the demo, try deleting the `dance!` method you added. Then in IRB:

```sh
> Skeleton.dance!
```

The skeleton can still dance! Things stick around because this reloader does not do any cleanup.

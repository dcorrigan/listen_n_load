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

In a separate terminal window, run `entr`:

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

The `listen_n_load.rb` file fires up a TCP server listening on a port (2222 in this case). When a file changes, the `reloader.sh` shellscript sends the name of the changed file to the listening server, and the Ruby code reloads it in the background. It does this within a thread; otherwise the TCP server would block IRB from loading when you required it.

This approach has some major drawbacks. For instance, while running the demo, try deleting the `dance!` method you added. Then in IRB:

```sh
> Skeleton.dance!
```

The skeleton can still dance! Things stick around because this reloader does not do any cleanup.

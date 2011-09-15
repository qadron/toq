# Arachni-RPC
<table>
    <tr>
        <th>Version</th>
        <td>0.1</td>
    </tr>
    <tr>
        <th>Github page</th>
        <td><a href="http://github.com/Arachni/arachni-rpc">http://github.com/Arachni/arachni-rpc</a></td>
     <tr/>
    <tr>
        <th>Documentation</th>
        <td><a href="http://github.com/Arachni/arachni-rpc/wiki">http://github.com/Arachni/arachni-rpc/wiki</a></td>
    </tr>
    <tr>
        <th>Code Documentation</th>
        <td><a href="http://arachni.github.com/arachni-rpc">http://arachni.github.com/arachni-rpc</a></td>
    </tr>
    <tr>
        <th>Google Group</th>
        <td><a href="http://groups.google.com/group/arachni">http://groups.google.com/group/arachni</a></td>
    </tr>
    <tr>
       <th>Author</th>
       <td><a href="mailto:tasos.laskos@gmail.com">Tasos</a> "<a href="mailto:zapotek@segfault.gr">Zapotek</a>" <a href="mailto:tasos.laskos@gmail.com">Laskos</a></td>
    </tr>
    <tr>
        <th>Twitter</th>
        <td><a href="http://twitter.com/Zap0tek">@Zap0tek</a></td>
    </tr>
    <tr>
        <th>Copyright</th>
        <td>2011</td>
    </tr>
    <tr>
        <th>License</th>
        <td><a href="file.LICENSE.html">GNU General Public License v2</a></td>
    </tr>
</table>

## Synopsis

Arachni-RPC is a simple and lightweight EventMachine based RPC client and server implementation. <br/>
It provides the basis for <a href="http://arachni.segfault.gr">Arachni</a>'s distributed infrastructure.

## Features

It's capable of:

 - performing and handling a few thousands requests per second (depending on call size, network conditions and the like)
 - TLS encrytion
 - asynchronous and synchronous requests
 - handling remote asynchronous calls that require a block

## Usage

Check out the files in the <i>examples/</i> directory, it goes through everything in great detail.

## Installation

### Gem

To install the Arachni-RPC gem:

    gem install arachni-rpc

### Source

If you want to clone the repository and work with the source code:

    git co git://github.com/arachni/arachni-rpc.git
    cd arachni-rpc
    rake install


## Bug reports/Feature requests
Please send your feedback using Github's issue system at
[http://github.com/arachni/arachni-rpc/issues](http://github.com/arachni/arachni-rpc/issues).


## License
Arachni is licensed under the GNU General Public License v2.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.


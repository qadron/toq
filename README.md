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
        <th>Code Documentation</th>
        <td><a href="http://rubydoc.info/github/Arachni/arachni-rpc/">http://rubydoc.info/github/Arachni/arachni-rpc/</a></td>
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

Arachni-RPC is a simple and lightweight Remote Procedure Call protocol currently under development
which will ultimately provide the basis for <a href="http://arachni.segfault.gr">Arachni</a>'s Grid infrastructure.

This repository holds *only* the protocol specification although there currently are 2 (more like 1.5) available implementations of the protocol:

 - Arachni-RPC EM -- Uses EventMachine for network related operations and provides both a client and a server, this is the one used by Arachni.
 - Arachni-RPC Pure -- Provides a synchronous client using pure Ruby OpenSSL sockets and has no 3rd party dependencies.

## Features

It is:

 - extremely lightweight
 - very simple design
 - provides token-based authentication

## Installation

I can't think of a lot of uses for manually installing the protocol specification
(it'll most likely be installed as a dependency for some other project) but in case you want to some instructions follow.

### Gem

The Gem hasn't been pushed yet, the system is still under development.

### Source

If you want to clone the repository and work with the source code:

    git co git://github.com/arachni/arachni-rpc.git
    cd arachni-rpc
    rake install


## Running the Specs

In order to run the specs you must first install RSpec:
    gem install rspec

Then:

    rake spec

## Bug reports/Feature requests
Please send your feedback using Github's issue system at
[http://github.com/arachni/arachni-rpc/issues](http://github.com/arachni/arachni-rpc/issues).


## License
Arachni is licensed under the GNU General Public License v2.<br/>
See the [LICENSE](file.LICENSE.html) file for more information.


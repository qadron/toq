require_relative 'server'

cwd = File.expand_path( File.dirname( __FILE__ ) )
opts = rpc_opts.merge(
    port:        7332,
    tls: {
        ca:          cwd + '/../pems/cacert.pem',
        private_key: cwd + '/../pems/server/key.pem',
        cert:        cwd + '/../pems/server/cert.pem',
        public_key:  cwd + '/../pems/server/pub.pem'
    }
)

start_server( opts )

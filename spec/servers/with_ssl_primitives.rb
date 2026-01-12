require_relative 'server'

cwd = File.expand_path( File.dirname( __FILE__ ) )
opts = rpc_opts.merge(
    port:        7332,
    ssl_ca:      cwd + '/../pems/cacert.pem',
    ssl_pkey:    cwd + '/../pems/server/key.pem',
    ssl_cert:    cwd + '/../pems/server/cert.pem',
    ssl_pubkey:  cwd + '/../pems/server/pub.pem'
)

start_server( opts )

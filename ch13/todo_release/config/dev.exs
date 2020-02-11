use Mix.Config

config :todo, http_port: 5454
config :todo, :database, pool_size: 3, folder: "./persist"

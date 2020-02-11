use Mix.Config

config :todo, http_port: 5456
config :todo, :database, pool_size: 3, folder: "./persist"

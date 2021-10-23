use Mix.Config

env = Mix.env()

if env == :test do
  # Vintage Net Mock
  config :vintage_net, resolvconf: "./resolv.conf"
end

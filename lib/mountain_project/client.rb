require 'faraday'

module MountainProject
  class Client
    class << self
      def get_ticks(email, mp_key)
        url =
          'https://www.mountainproject.com/data/get-ticks?' \
          "email=#{email}&key=#{mp_key}"

        resp = Faraday.get(url)
        JSON.parse(resp.body)['ticks']
      end

      def get_routes(route_ids, mp_key)
        url =
          'https://www.mountainproject.com/data/get-routes?' \
          "routeIds=#{route_ids}&key=#{mp_key}"

        resp = Faraday.get(url)
        JSON.parse(resp.body)['routes']
      end
    end
  end
end

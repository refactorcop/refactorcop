class Rack::Attack
  throttle('projects/:id/send_cops', limit: 5, period: 60.seconds) do |req|
    if req.path =~ /\/projects\/\d+\/send_cops/i
      req.ip
    end
  end
end

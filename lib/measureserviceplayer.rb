class Provider
  def initialize(header)
    @header = header
  end

  def type
    type = 'UNTYPED'
    if self.name == 'YOSPACE' then
      type = 'ADS'
    elsif self.name == 'VIAPLAY' then
      type = 'SVOD'
    elsif self.name == 'YOUTUBE' then
      type = 'CLIP'
    end
    type
  end

  def name
    name = 'UNKNOWN'
    if @header['Host'].match(/viasat.tv/) then
      name = 'VIAPLAY'
    elsif @header['Host'].match(/yospace.com/) then
      name = 'YOSPACE'
    elsif @header['Host'].match(/googlevideo.com/) then
      name = 'YOUTUBE'
    else
      puts "Unknown provider: #{@header['Host']}"
      puts @header.inspect
    end
    name
  end
end

class MeasureServicePlayer
  
  def initialize(header)
    @header = header
    @provider = Provider.new(header)
  end

  def is_playing
    playing = false
    if @header['X-Playback-Session-Id'] then
      playing = @header['X-Playback-Session-Id'].empty? ? false : true
      @sessionid = @header['X-Playback-Session-Id']
    end
    playing
  end

  def provider
    @provider
  end

  def session
    @sessionid
  end
end

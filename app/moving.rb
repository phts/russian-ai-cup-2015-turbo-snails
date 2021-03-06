require_relative 'env'

class Moving
  TICK_COUNT_WHEN_GOT_STUCK = 40
  TICK_COUNT_LIMIT_WHEN_GOT_STUCK = 200
  REPARING_POSITION_TICK_COUNT = 150

  def initialize
    @low_speed_count = 0
    @reparing_position_ticks = 0
  end

  def got_stuck?
    return false unless Env.started?
    if reparing_position?
      @low_speed_count = 0
      if @reparing_position_ticks > REPARING_POSITION_TICK_COUNT
        @reparing_position_ticks = 0
        return false
      else
        return true
      end
    end
    if Env.me.speed < 0.1
      @low_speed_count += 1
    else
      @low_speed_count = 0
    end
    return (TICK_COUNT_WHEN_GOT_STUCK..TICK_COUNT_LIMIT_WHEN_GOT_STUCK).include? @low_speed_count
  end

  def reparing_position?
    @reparing_position_ticks != 0
  end

  def repare_position(subwaypoints)
    @reparing_position_ticks += 1
    if @reparing_position_ticks == REPARING_POSITION_TICK_COUNT
      subwaypoints.use_rebuilt_path_to_next(Env.me.tile)
    end
    Env.move.engine_power = -1.0
    Env.move.wheel_turn = -Env.move.wheel_turn
    Env.move.brake = false
    if REPARING_POSITION_TICK_COUNT - @reparing_position_ticks < 30
      Env.move.engine_power = 1.0
      Env.move.brake = true
    end
  end

end

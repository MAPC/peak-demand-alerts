module ApplicationHelper
  def cell_style(f)
    str = "background-color: #{risk_background(f)}; color: #{risk_text_color(f)};"
    # str << "border: 4px solid red;" if f.risk_level == 'likely'
    str << 'text-align: center;' if f.today?
    str
  end

  def risk_level_style(f)
    str = "background-color: #{risk_box_background(f)};"
    str << "color: #{risk_box_text_color(f)};"
    unless f.risk_level == 'likely'
      str << "border: #{header_border_size(f)} solid #{risk_color(f)};"
    end
    str << 'text-align: center;'
    str
  end

  def header_style(f)
    str = "color: #{risk_text_color(f)};"
    str << "border-top: #{header_border_size(f)} solid #{risk_color(f)};"
    str << "background-color: #{risk_background(f)};"
    str << "font-weight: #{header_font_weight(f)};"
    str
  end

  private

  def header_border_size(f)
    f.today? ? '5px' : '3px'
  end

  def header_font_weight(f)
    f.today? ? 'bolder' : 'normal'
  end

  def risk_background(f)
    'red' if f.risk_level == 'likely'
  end

  def risk_box_background(f)
    case f.risk_level
    when 'likely' then 'red'
    when 'possible' then 'orange'
    end
  end

  def risk_text_color(f)
    f.risk_level == 'likely' ? '#FFF' : '#000'
  end

  def risk_box_text_color(f)
    'white' if %w[likely possible].include?(f.risk_level)
  end

  def risk_color(f)
    case f.risk_level
    when 'likely'   then 'red'
    when 'possible' then 'orange'
    when 'unlikely' then 'green'
    end
  end
end

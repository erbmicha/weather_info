module LocationsHelper
  def usa_date(date)
    if date.is_a?(String)
      Date.parse(date).to_fs(:usa)
    elsif date.is_a?(Date)
      date.to_fs(:usa)
    end
  end
end

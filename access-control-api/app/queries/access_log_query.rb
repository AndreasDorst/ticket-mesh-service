class AccessLogQuery
  def initialize(params = {})
    @params = params
  end

  def call
    logs = AccessLog.joins(:ticket)
    logs = filter_by_type(logs)
    logs = filter_by_status(logs)
    logs = filter_by_date(logs)
    logs
  end

  private

  def filter_by_type(logs)
    return logs unless @params[:type]

    logs.where(access_logs: { status: @params[:type] })
  end

  def filter_by_status(logs)
    return logs unless @params[:status]

    logs.where(access_logs: { status: @params[:status] })
  end

  def filter_by_date(logs)
    return logs unless @params[:date]

    logs.where('DATE(access_logs.check_time) = ?', @params[:date])
  end
end
class ServiceError < StandardError; end

class TicketAlreadyInsideError < ServiceError; end
class TicketNotInsideError < ServiceError; end
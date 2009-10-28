# Options:
# * :tries - Number of retries to perform. Defaults to 1.
# * :on - The Exception on which a retry will be performed. Defaults to Exception, which retries on any Exception.
#
# Example
# =======
#   retryable(:tries => 1, :on => OpenURI::HTTPError) do
#     # your code here
#   end
#
class Object
  def retryable(options = {}, &block)
    opts = { :tries => 1, :on => StandardError }.merge(options)

    retry_exception, retries = opts[:on], opts[:tries]

    begin
      return yield
    rescue retry_exception
      unless opts[:sleep].nil?
        puts "sleeping"
        sleep opts[:sleep] 
      end

      retry if (retries -= 1) > 0
    end

    yield
  end
end

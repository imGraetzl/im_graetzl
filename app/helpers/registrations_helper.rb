module RegistrationsHelper

  def count_graetzl(graetzls)
    if graetzls.empty?
      'leider kein'
    else
      graetzls.size
    end    
  end
end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_flash
    unless flash.empty?
      flashes = flash.collect { |k, v| content_tag(:div, v, :class => k) }
      content_tag(:div, flashes, :class => :flash)
    end
  end
  
  def show_nav
    capture_haml do
      haml_tag :ul do
        # %w(documents tags users).each do |item|
        #   haml_tag :li do
        #     haml_concat link_to(
        #       "#{item.titlecase}", 
        #       send("#{item}_path")
        #     )
        #   end
        # end
        haml_tag(:li, link_to("Concepts"))
        haml_tag(:li, link_to("Experts"))
      end
    end
  end
  
  def show_type(document)
    type = document.doc_type
    content_tag(:span, type.titlecase, :class => type.downcase)
  end
  
  def link_to_user(name)
    user = User.find(:first, :from => :by_name, :params => { :name => name })
    link_to user.full_name, user
  end
  
  def link_to_children(superclass, concepts = nil)
    unless @concept_hash
      @concept_hash = {}
      concepts.each do |c| 
        @concept_hash[c.superclass] ||= []
        @concept_hash[c.superclass] << c unless c.superclass == c.name
      end
    end
    
    capture_haml do
      haml_tag :ul do
        subconcepts = @concept_hash[superclass]
        subconcepts && subconcepts.each do |concept|
          haml_tag :li, link_to(concept.link_title, tags_path(:id => concept.name))
          haml_concat link_to_children(concept.name)
        end
      end
    end
  end
end

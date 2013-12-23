class Scheduler.EditTicketView extends Backbone.View
  tagName: 'tr'
  className: 'ticket'
  
  events:
    'click': 'putFocusInFirstInput'
    'focus input': 'takeFocus'
    'blur input': 'loseFocus'
    'change input': 'saveValue'
    'click .btn-unable-to-estimate': 'onToggleUnableToEstimate'
  
  
  
  initialize: ->
    @ticket = @options.ticket
    @template = @options.template
    @isValid = @options.isValid
    @attribute = @options.attribute
    @unableToSetAttribute = "unableToSet#{@attribute[0].toUpperCase()}#{@attribute.substr(1)}"
    @$el.cssHover()
  
  render: ->
    @$el
      .attr('id', "ticket_#{@ticket.get('id')}")
      .html(@template @ticket.toJSON())
      .toggleClass('saved', @isValid(@ticket))
    @unableToEstimate() if @ticket.get(@unableToSetAttribute)
    @
  
  
  
  putFocusInFirstInput: ->
    @$el.find('input:first').focus()
  
  takeFocus: ->
    @$el.addClass('focus')
  
  loseFocus: ->
    @$el.removeClass('focus')
  
  
  
  saveValue: ->
    attributes = @$el.serializeFormElements()
    @saveAttributes attributes, =>
      @$el.toggleClass('saved', @isValid(@ticket))
  
  saveAttributes: (attributes, callback)->
    @ticket.save attributes,
      patch: true
      beforeSend: =>
        @$el.addClass 'working'
      success: =>
        @$el.removeClass 'working'
        callback()
      error: =>
        console.log arguments
        @$el.removeClass 'working'
      complete: =>
        @$el.removeClass 'working'
  
  
  
  onToggleUnableToEstimate: (e)->
    e.preventDefault()
    
    attributes = {}
    attributes[@unableToSetAttribute] = disableMe = if @$el.hasClass('unable-to-estimate') then null else true
    @unableToEstimate() if disableMe
    
    @saveAttributes attributes, =>
      @updateAbilityToEstimate()
  
  updateAbilityToEstimate: ->
    if @ticket.get(@unableToSetAttribute)
      @unableToEstimate()
    else
      @ableToEstimate()
  
  unableToEstimate: ->
    @$el.addClass('unable-to-estimate').removeClass('focus')
    @$el.find('button').addClass('active')
    @$el.find('input').attr('disabled', 'disabled')
  
  ableToEstimate: ->
    @$el.removeClass('unable-to-estimate')
    @$el.find('button').removeClass('active')
    @$el.find('input').removeAttr('disabled').focus().select()


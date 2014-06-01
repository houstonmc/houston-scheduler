class Scheduler.EditBugSeverityView extends Backbone.View
  
  events:
    'change input[type="number"]': 'saveValue'
    'keypress input[type="number"]': 'onKeyPress'
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/assess_bug']
    @$el.addClass('assess-severity')
  
  render: ->
    @$el.html @template(@ticket.toJSON())
    
    view = @
    @$el.find('[rel="slider"]').simpleSlider
      range: [1, 10]
      step: 1
      snap: true
      highlight: true
    .bind 'slider:changed', (e, data)->
      name = $(@).attr('name')
      $input = $("input[type=\"number\"][name=\"#{name}\"]")
      $input.val(data.value)
      view.saveValue.apply(view, [target: $input[0]])
    
    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    @$el.delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()
    
    @$el.find('input[type="number"]:first').focus()
    @$el.find('[data-toggle="tooltip"]').tooltip()
    @$el.toggleClass('saved', @ticket.severity())
    @
  
  
  
  saveChanges: ->
    @$el.find('input:first').blur()
  
  saveValue: (e)->
    $input = $(e.target)
    name = $input.attr('name')
    value = $input.val()
    @$el.find("input[rel=\"slider\"][name=\"#{name}\"]")
      .simpleSlider('setValue', value)
    
    attributes = {}
    attributes[name] = value
    @saveAttributes @ticket, attributes, =>
      @$el.toggleClass('saved', @ticket.severity())
  
  saveAttributes: (model, attributes, callback)->
    model.save attributes,
      patch: true
      wait: true
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



  onKeyPress: (e)->
    character = String.fromCharCode(e.charCode)
    value = $(e.target).val() + character
    e.preventDefault() unless /^[\d\.]+$/.test(value)
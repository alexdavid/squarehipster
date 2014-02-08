# application coffeescript goes here

class Thing
  constructor: ({ el, @x, @y }) ->
    @el = $ el
    @width = @el.width()
    @height = @el.height()

  tick: ->
    @update()

  update: ->
    @el.css
      top: @y
      left: @x



class Platform extends Thing



class Hero extends Thing
  constructor: ->
    super
    @max_x_acc = 10
    @x_acc = 0
    @y_acc = 0
    new BindKeyEvents @

  tick: (objects) ->
    console.log @x_acc
    blocked = no
    for object in objects
      continue if object.y > @y + @y_acc
      continue if object.x > @x + @width / 2
      continue if object.x + object.width < @x - @width / 2
      @y = object.y
      blocked = yes
    @x += @x_acc
    if blocked
      @y_acc = 0
    else
      @y += @y_acc
    super
    @y_acc++

  jump: ->
    @y_acc = -10

class SquareHipster
  constructor: ->
    @objects = []
    @hero = new Hero el: '#hero', x: 170, y: 100

    @add_platform new Platform el: '.platform.p1', x: 40, y: 200
    @add_platform new Platform el: '.platform.p2', x: 80, y: 400

    setInterval @tick, 16

  add_platform: (platform) ->
    @objects.push platform

  tick: =>
    @hero.tick(@objects)
    for object in @objects
      object.tick()


class BindKeyEvents
  constructor: (@hero) ->
    Mousetrap.bind 'left', () =>
      @hero.x_acc-- if @hero.x_acc > -(@hero.max_x_acc)
    Mousetrap.bind 'right', () =>
      @hero.x_acc++ if @hero.x_acc < @hero.max_x_acc
    Mousetrap.bind 'space', () =>
      @hero.jump()


new SquareHipster


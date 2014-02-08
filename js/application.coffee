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
    @objects = objects
    blocked = no
    for object in objects
      continue if object.y < @y
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

  canJump: () ->
    _.some(@objects, (object) => object.y == @y)

  jump: ->
    @y_acc = -10 if @canJump()

class SquareHipster
  constructor: ->
    @objects = []
    @hero = new Hero el: '#hero', x: 170, y: 100

    @add_platform new Platform el: '.platform.p1', x: 40, y: 200
    @add_platform new Platform el: '.platform.p2', x: 80, y: 400
    @add_platform new Platform el: '.platform.ground', x: 0, y: innerHeight - 50

    @tick()

  add_platform: (platform) ->
    @objects.push platform

  tick: =>
    @hero.tick(@objects)
    for object in @objects
      object.tick()
    requestAnimationFrame @tick


class BindKeyEvents
  constructor: (@hero) ->
    Mousetrap.bind 'left', () =>
      @hero.x_acc -= 1 if @hero.x_acc > -(@hero.max_x_acc)
    Mousetrap.bind 'right', () =>
      @hero.x_acc += 1 if @hero.x_acc < @hero.max_x_acc
    Mousetrap.bind ['left', 'right'], () =>
      @hero.x_acc = 0
    , 'keyup'
    Mousetrap.bind 'space', () =>
      @hero.jump()


new SquareHipster


# application coffeescript goes here


running = yes

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


class Guy extends Thing
  constructor: ->
    super
    @x_acc = 0
    @y_acc = 0

  tick: (@objects) ->
    @blocked = no
    if @y_acc > 0
      for object in objects
        continue if object.y < @y
        continue if object.y > @y + @y_acc
        continue if object.x > @x + @width / 2
        continue if object.x + object.width < @x - @width / 2
        @y = object.y
        @blocked = yes

    @x += @x_acc
    if @blocked
      @y_acc = 0
    else
      @y += @y_acc
    super
    @y_acc++

  canJump: -> @blocked

  jump: ->
    @y_acc = -20 if @canJump()


class Platform extends Thing
  constructor: (args) ->
    if args.el
      super args
    else
      args.el = $ '<div class="platform">'
      args.el.appendTo 'body'
      super args



class Enemy extends Guy
  constructor: (args) ->
    args.el = $ '<div class="enemy">'
    args.el.appendTo 'body'
    for supporting_element in ['head', 'body', 'legs front', 'legs back', 'tie']
      args.el.append "<div class='#{supporting_element}'>"
    super args
    @x_acc = -3 * Math.random()

  tick: ->
    super
    @jump()
    if @x < 0
      @x = innerWidth

  jump: ->
    @y_acc = -30 * Math.random() if @canJump()


class Hero extends Guy
  constructor: ->
    super
    @max_x_acc = 20
    @test_condition_delayer = 0
    new BindKeyEvents @

  tick: (objects, enemies) ->
    super
    @test_condition_delayer++
    if @test_condition_delayer > 10
      if @x > innerWidth - 100 and @y > innerHeight - 100
        running = no
        ($ '.message').html "Welcome to Portlandia, bro. <br> <img src='http://imgur.com/r4x09Zr.png'>"
      for enemy in enemies
        if @x + @width > enemy.x and @x - @width < enemy.x and @y + @height > enemy.y and @y - @height < enemy.y
          running = no
          ($ '.message').html "You're too <span class='mainstream'>mainstream</span>"
      @test_condition_delayer = 0
    @x = Math.max(30, @x)
    @x = Math.min(@x, innerWidth)

  update: ->
    super
    if @x_acc isnt 0 or @y_acc isnt 0
      @el.addClass 'walking'
    else
      @el.removeClass 'walking'
    if @x_acc < 0
      @el.addClass 'left'
    else if @x_acc > 0
      @el.removeClass 'left'


class SquareHipster
  constructor: ->
    @num_platforms = 20
    @objects = []
    @enemies = []
    @hero = new Hero el: '#hero', x: 170, y: 100
    @add_enemy new Enemy x: innerWidth, y: innerHeight - 100
    @add_enemy new Enemy x: innerWidth, y: innerHeight - 100
    @add_enemy new Enemy x: innerWidth, y: innerHeight - 100
    @add_enemy new Enemy x: innerWidth, y: Math.random() * 400
    @add_enemy new Enemy x: innerWidth, y: Math.random() * 400
    @add_enemy new Enemy x: innerWidth, y: Math.random() * 400
    @add_enemy new Enemy x: innerWidth, y: Math.random() * 400

    for column in [1..@num_platforms]
      @generate_platform(column)

    @add_platform new Platform el: '.platform.ground', x: 0, y: innerHeight - 50
    @add_platform (new Platform {x: 100, y: 567})
    @tick()


  add_enemy: (enemy) ->
    @enemies.push enemy


  add_platform: (platform) ->
    @objects.push platform

  generate_platform: (column) ->
    column_width = 200
    floor = innerHeight
    x = (column * column_width) + Math.floor(Math.random() * column_width)
    y = floor - 50 - Math.floor(Math.random() * 500)
    coords = {x: x, y: y}
    @add_platform (new Platform coords)

  tick: =>
    @hero.tick @objects, @enemies
    for object in @objects
      object.tick()
    for enemy in @enemies
      enemy.tick @objects
    requestAnimationFrame @tick if running

class BindKeyEvents
  constructor: (@hero) ->
    Mousetrap.bind 'left', () =>
      @hero.x_acc = -5
    Mousetrap.bind 'right', () =>
      @hero.x_acc = 5
    Mousetrap.bind ['left', 'right'], () =>
      @hero.x_acc = 0
    , 'keyup'
    Mousetrap.bind 'space', () =>
      @hero.jump()


new SquareHipster


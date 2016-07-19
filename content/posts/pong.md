---
title: Pong for Pico-8
date: 2015-12-23T06:55:43
tags: [frew-warez, pong, pico-8, lua]
guid: "https://blog.afoolishmanifesto.com/posts/pong-for-pico-8"
---
I originally wrote this for the [Pico-8
Fanzine](http://pico8fanzine.bigcartel.com/) but it was sadly not accepted.  I
still had a lot of fun writing in a totally different style than usual.
Imagine the following has been printed out, scanned, and reprinted maybe five
times.

[Pico-8](http://www.lexaloffle.com/pico-8.php) is a "fantasy console."  It's a
reimagined 8-bit console sorta like the [Commadore
64](https://en.wikipedia.org/wiki/Commodore_64) but with
[Lua](http://www.lua.org) as the primary language instead of BASIC.  It's very
fun to play with and I think anyone interested in making games would do well to
get it, even if it's nothing like real life games.  It takes away the
superficial hurdles and lets you just build a game.  Anyway, without further
ado, my article:

{{< highlight lua >}}
-- pong
--   <3 frew

-- this is a simple pong game
-- written to learn pico-8 and
-- basic game programming.

-- the structure should be
-- fairly easy to understand,
-- but i'll write out some
-- notes in these comments to
-- help others learn.

------------------------------

-- first off, we have the
-- following two "player" or
-- "paddle" objects.  they have
-- six members each:
--
--  x      - the column
--  y      - the row
--  h      - the height
--  score
--  ai     - computer controlled
--  player - which player

l = {
  x      =  5,
  y      = 50,
  h      = 10,
  score  =  0,
  ai     = true,
  player = 1
}

r = {
  x      = 123,
  y      = 50,
  h      = 10,
  score  =  0,
  ai     = true,
  player = 0
}

-- this is the first really
-- interesting piece of code.
-- for a given player, it will
-- move the player up or down
-- if the ball is not directly
-- across from the center.
--
-- you could improve this code
-- in a few easy ways.  first
-- off, you could make it try
-- to hit the ball with the
-- edge of the paddle, which
-- is harder to anticipate.
-- you could also add some code
-- to make it move more
-- gracefully.  finally, you
-- could make it worse, so that
-- the player actually has a
-- chance!
function do_ai(p, b)
  if (b.y < p.y + p.h/2) then
     p.y -= 1
  elseif (b.y > p.y + p.h/2) then
     p.y += 1
  end
end

-- this is pretty obvious code,
-- except for one part.  the
-- main bit just moves the
-- piece up or down based on
-- the button pressed.  but it
-- additionally maintains the
-- 'ai' member of the player,
-- and automatically calls the
-- do_ai() function above if
-- the player is still an ai.
--
-- it might be fun to add a
-- button that would turn the
-- ai back on after a player
-- took over for the ai.
function update_player(p, b)
  if (btn(2, p.player) or btn(3, p.player)) then
    p.ai = false
  end

  if (not p.ai) then
    if (btn(2, p.player)) p.y -= 1
    if (btn(3, p.player)) p.y += 1
  else
    do_ai(p, b)
  end
end

-- not too complicated, move
-- the ball up and over in the
-- direction it is moving.
function update_ball(b)
  b.x += b.dx
  b.y += b.dy
end

-- this function just puts the
-- ball back in the middle
-- after a point is scored.
middle = r.y + r.h/2
function reset_ball(b)
  b.x  = 50
  b.y  = middle
  b.h  = 2
  b.dx = 1
  b.dy = 0
end

-- and we call it at the start
-- of the game too.
b = {}
reset_ball(b)

-- this is a pretty complex
-- function, but the code is
-- not that hard to understand.
function intersection(l, r, b)
  -- calc_angle will be true
  -- if a player hit the ball.
  calc_angle = false
  -- and p will be set to which
  -- player hit the ball.
  p = {}

  -- ball passed left paddle
  if (b.x < 0) then
     r.score += 1
     reset_ball(b)
  -- ball passed right paddle
  elseif (b.x > 128) then
     l.score += 1
     reset_ball(b)
  -- ball hit ceiling or floor
  elseif (
    b.y < 0 or b.y > 128) then
     b.dy = -b.dy
  -- ball hit left paddle
  elseif (b.x < l.x and
      b.y >= l.y - b.h and
      b.y <= l.y + l.h + b.h
     ) then
     b.dx = -b.dx
     calc_angle = true
     p = l
  -- ball hit right paddle
  elseif (b.x > r.x and
      b.y >= r.y - b.h and
      b.y <= r.y + r.h + b.h
     ) then
     b.dx = -b.dx
     calc_angle = true
     p = r
  end

  if (calc_angle) then
     -- every now and then
     -- increase ball speed
     if (rnd(1) > 0.9) then
       b.dx *= 1 + rnd(0.01)
     end

     -- this is complicated!
     -- the first line scales
     -- the location that the
     -- ball hit the paddle
     -- from zero to one.  so
     -- if the ball hit the
     -- paddle one third of the
     -- way from the top, it
     -- will be set to
     -- circa 0.3
     rl = (b.y - p.y)/p.h
     
     -- this basically makes it
     -- as if the paddle were
     -- part of a circle, so
     -- that bouncing off the
     -- middle is flat, the top
     -- is a sharp angle, and
     -- the bottom is a sharp
     -- angle.  i had to look
     -- up sin and cosine for
     -- this, but it might be
     -- just as easy to play
     -- with the numbers till
     -- you get what you want
     rl = rl / 2 + 0.25
     angle = sin(rl)

     b.dy = angle
     
     -- boop
     sfx(0)
  end
end

-- call all functions above
function _update()
  update_player(l, b)
  update_player(r, b)
  update_ball(b)

  intersection(l, r, b)
end

-- this is pong, everything
-- is basically a square :)
function drawshape(s)
  rectfill(s.x  , s.y    ,
           s.x+2, s.y+s.h, 7 )
end

function _draw()
  cls()
  drawshape(l)
  drawshape(r)
  drawshape(b)

  -- draw the dotted line in
  -- the middle of the field
  for i=0,30 do
    rectfill(64  , i*5  ,
             64+2, i*5+2,  7)
  end

  print(l.score, l.x + 5, 5)
  print(r.score, r.x - 5, 5)
end
{{< / highlight >}}

Here is the actual catridge; the code is embedded in the image:

![pong](/static/img/pong.p8.png)

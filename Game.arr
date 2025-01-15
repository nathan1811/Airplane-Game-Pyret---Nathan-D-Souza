import image as I
import reactors as R

# Position and world data structures
data Posn:
  | posn(x, y)
end

data World:
  | world(p :: Posn, b :: Posn,  b1 :: Posn,  b2 :: Posn,  b3 :: Posn,  b4 :: Posn, f :: Number, r :: Number, s :: Posn)
end

# Constants for game settings
AIRPLANE-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1qTTywNtfX9EKyR14pIguTd9eYFyuuTNF"
AIRPLANE = I.image-url(AIRPLANE-URL)

SHIP-URL = "https://cdn.creazilla.com/cliparts/10007/pirate-ship-clipart-original.png"
SHIP = I.image-url(SHIP-URL)
PYRET-SHIP = I.scale(0.1, SHIP) # Scale the PYRET-SHIP to 10% of its original size

PYRET-URL = "https://www.pyret.org/img/pyret-logo.png"
PYRET = I.image-url(PYRET-URL)
PYRET-LOGO = I.scale(0.1, PYRET) # Scale the PYRET-LOGO to 10% of its original size

BIRD-URL = "https://cdn-icons-png.flaticon.com/256/6438/6438101.png"
BIRD = I.image-url(BIRD-URL)
SMALL-BIRD = I.scale(0.3, BIRD)  # Scale the nird to 30% of its original size
SMALLER-BIRD = I.scale(0.5, BIRD) # Scale the bird to 50% of its original size
SMALLEST-BIRD = I.scale(0.2, BIRD) # Scale the bird to 20% of its original size

FUEL-URL = "https://i.pinimg.com/736x/85/75/2d/85752d5215fb171aed050017e7ab61c6.jpg"
FUEL-TANK = I.image-url(FUEL-URL)
FUEL = I.scale(0.06, FUEL-TANK) # Scale the Fuel Tank to 6% of its original size
 
# Backdrop Image

# Scene setup with backdrop

WIDTH = 800
HEIGHT = 500
BASE-HEIGHT = 50
WATER-WIDTH = 500

# Airplane and balloon movement settings
AIRPLANE-X-MOVE = 10
AIRPLANE-Y-MOVE = 3
BIRD-X-MOVE = -6  # Bird moves leftwards
BIRD-Y-MOVE = -5  # Bird moves upwards
KEY-DISTANCE = 10

# Scene
BLANK-SCENE = I.rectangle(WIDTH, HEIGHT, "solid", "lightblue")
WATER = I.rectangle(WATER-WIDTH, BASE-HEIGHT, "solid", "blue")
LAND = I.rectangle(WIDTH - WATER-WIDTH, BASE-HEIGHT, "solid", "brown")
BASE = I.beside(WATER, LAND)



BACKGROUND =
  I.place-image(BASE, WIDTH / 2, HEIGHT - (BASE-HEIGHT / 2), I.place-image(PYRET-LOGO,
      210, 340, I.place-image(PYRET-SHIP,
        200, 370, BLANK-SCENE)))

fun collision(p1, p2, threshold):
  num-sqrt(((p1.x - p2.x) * (p1.x - p2.x)) + ((p1.y - p2.y) * (p1.y - p2.y))) < threshold
end
# Move airplane horizontally with wrapping behavior
fun move-airplane-wrapping-x-on-tick(x):
  num-modulo(x + AIRPLANE-X-MOVE, WIDTH)
end

# Move airplane vertically
fun move-airplane-y-on-tick(y):
  y + AIRPLANE-Y-MOVE
end

# Move bird vertically
fun move-bird-y-on-tick(b):
  if b.y < 0: 
    posn(WIDTH, HEIGHT)
  else: 
    posn(b.x + BIRD-X-MOVE, b.y + BIRD-Y-MOVE)
  end
end

fun move-fuel-x-on-tick(s):
  if s.x < 0:
    posn(WIDTH, num-random(HEIGHT))  # Resetting the fuel take to a random position when it moves out of screen
  else:
    posn(s.x - 5, s.y)  # Moving the fuel tank to the left
  end
end

# Place both airplane and bird on the scene
fun place-airplane-xy(w :: World):
  I.place-image(
    I.text("Score: " + num-to-string(w.r), 20, "black"), 
    50, 20,
    I.place-image(
      I.text("Fuel: " + num-to-string(w.f), 20, "black"), 
      50, 45,
    I.place-image(AIRPLANE, w.p.x, w.p.y, 
      I.place-image(SMALLER-BIRD, w.b.x, w.b.y, 
        I.place-image(SMALL-BIRD, w.b1.x, w.b1.y, 
          I.place-image(SMALLER-BIRD, w.b2.x, w.b2.y, 
            I.place-image(SMALLEST-BIRD, w.b3.x, w.b3.y,
                I.place-image(FUEL, w.s.x, w.s.y, BACKGROUND))))))))
end


fun collect-fuel(w :: World):
  ask:
    | distance(w.p, w.s) < 100 then:
      world(w.p, w.b, w.b1, w.b2, w.b3, w.b4, w.f + 8, w.r + 15, posn(WIDTH, num-random(HEIGHT)))
    | otherwise: w
  end
end

fun move-airplane-xy-on-tick(w :: World):
  collect-fuel(world(
    posn(move-airplane-wrapping-x-on-tick(w.p.x), move-airplane-y-on-tick(w.p.y)),
      move-bird-y-on-tick(w.b),
    move-bird-y-on-tick(w.b1),
    move-bird-y-on-tick(w.b2),
    move-bird-y-on-tick(w.b3),
    move-bird-y-on-tick(w.b4),
      w.f, w.r, move-fuel-x-on-tick(w.s))
      )
end


# Handle key presses to move the airplane vertically
fun alter-airplane-y-on-key(w :: World, key):
  ask:
    | key == "up"   then:
      if w.f > 0:
        world(posn(w.p.x, w.p.y - KEY-DISTANCE), w.b, w.b1, w.b2, w.b3, w.b4, w.f - 1, w.r - 1, w.s)
      else:
        w
      end
    | key == "down" then:
      world(posn(w.p.x, w.p.y + KEY-DISTANCE), w.b, w.b1, w.b2, w.b3, w.b4, w.f, w.r, w.s)
    | otherwise: w
  end
end

# to check if the airplane has landed or hit the bird
fun game-ends(w :: World):
  ask:
    | w.p.y >= (HEIGHT - BASE-HEIGHT) then: true
    | distance(w.p, w.b) < 75         then: true
    | distance(w.p, w.b1) < 75         then: true
    | distance(w.p, w.b2) < 75         then: true
    | distance(w.p, w.b3) < 75         then: true
    | distance(w.p, w.b4) < 10         then: true
    | otherwise: false
  end
end

# Calculate the distance between two positions
fun distance(p1, p2):
  num-sqrt((p1.x - p2.x) * (p1.x - p2.x) ) + ((p1.y - p2.y) * (p1.y - p2.y))
end

# Initial world state
INIT-POS = world(posn(0, 0), posn(340, 200),posn(559, 392), posn(710, 847), posn(600, 276), posn(200, 370), 100, 100, posn(WIDTH, num-random(HEIGHT)))

# Run the animation
anim = reactor:
  init: INIT-POS,
  on-tick: move-airplane-xy-on-tick,
  on-key: alter-airplane-y-on-key,
  to-draw: place-airplane-xy,
  stop-when: game-ends
end

R.interact(anim)




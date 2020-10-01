import 'package:flutter/material.dart';

import 'ball.dart';
import 'bat.dart';

import 'dart:math';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  int score = 0;

  Direction vDir = Direction.down;
  Direction hDir = Direction.right;

  double randX = 1;
  double randY = 1;

  double width;
  double height;
  double posX;
  double posY;
  double batWidth;
  double batHeight;
  double batPosition = 200;

  Animation<double> animation;
  AnimationController controller;

  double increment = 10;

  @override
  void initState() {
    posX = 0;
    posY = 0;

    controller = AnimationController(
        duration: const Duration(minutes: 10000), vsync: this);

    animation = Tween<double>(begin: 0, end: 50).animate(controller);

    animation.addListener(() {
      safeSetState(() {
        hDir == Direction.right
            ? posX += (increment * randX.round())
            : posX -= (increment * randX.round());
        vDir == Direction.down
            ? posY += (increment * randY.round())
            : posY -= (increment * randY.round());
      });
      checkBorders();
    });

    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pong"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraint) {
            height = constraint.maxHeight;
            width = constraint.maxWidth;
            batHeight = height / 20;
            batWidth = width / 5;
            return Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 24,
                  child: Text('Score: ' + score.toString()),
                ),
                Positioned(
                  child: Ball(),
                  top: posY,
                  left: posX,
                ),
                Positioned(
                  child: GestureDetector(
                      onHorizontalDragUpdate: (DragUpdateDetails update) =>
                          moveBat(update),
                      child: Bat(
                        height: batHeight,
                        width: batWidth,
                      )),
                  bottom: 0,
                  left: batPosition,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Game Over",
              style: TextStyle(fontSize: 20),
            ),
            content: Text("Would you like to play again"),
            actions: [
              FlatButton(
                onPressed: () {
                  setState(() {
                    posX = 0;
                    posY = 0;
                    score = 0;
                  });

                  Navigator.of(context).pop();
                  controller.repeat();
                },
                child: Text("Yes"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.dispose();
                },
                child: Text("No"),
              ),
            ],
          );
        });
  }

  checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }

    if (posX >= (width - diameter) && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }

    if (posY >= (height - diameter - batHeight) && vDir == Direction.down) {
      //check if the bat is here , otherwise loose
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
        setState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }

    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }

  randomNumber() {
    var ran = new Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }
}

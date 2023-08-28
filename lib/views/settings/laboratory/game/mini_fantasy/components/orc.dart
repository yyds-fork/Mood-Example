import 'dart:math';
import 'package:flutter/material.dart';

///
import 'package:bonfire/bonfire.dart';

///
import '../sprite_sheet/sprite_sheet_orc.dart';

double tileSize = 20.0;

class Orc extends SimpleEnemy
    with ObjectCollision, AutomaticRandomMovement, UseBarLife {
  Orc(Vector2 position)
      : super(
          position: position,
          animation: SimpleDirectionAnimation(
            idleLeft: SpriteSheetOrc.getIdleBottomLeft(),
            idleRight: SpriteSheetOrc.getIdleBottomRight(),
            idleDownRight: SpriteSheetOrc.getIdleBottomRight(),
            idleDownLeft: SpriteSheetOrc.getIdleBottomLeft(),
            idleUpRight: SpriteSheetOrc.getIdleTopRight(),
            idleUpLeft: SpriteSheetOrc.getIdleTopLeft(),
            idleUp: SpriteSheetOrc.getIdleTopRight(),
            idleDown: SpriteSheetOrc.getIdleBottomRight(),
            runLeft: SpriteSheetOrc.getRunBottomLeft(),
            runRight: SpriteSheetOrc.getRunBottomRight(),
            runUpLeft: SpriteSheetOrc.getRunTopLeft(),
            runUpRight: SpriteSheetOrc.getRunTopRight(),
          ),
          speed: tileSize * 3 + Random().nextInt(20),
          size: Vector2.all(tileSize * 2.9),
        ) {
    /// 设置碰撞系统
    setupCollision(
      CollisionConfig(
        collisions: [
          /// 碰撞形状及体积
          CollisionArea.rectangle(
            size: Vector2(
              size.x * 0.3,
              size.y * 0.2,
            ),
            align: Vector2(tileSize * 1, tileSize * 1.5),
          ),
        ],
      ),
    );

    /// 生命条
    setupBarLife(
      size: Vector2(tileSize * 1.5, tileSize / 5),
      barLifePosition: BarLifePorition.top,
      showLifeText: false,
      margin: 0,
      borderWidth: 2,
      borderColor: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(2),
      offset: Vector2(0, tileSize * 0.5),
    );
  }

  bool canMove = true;

  /// 渲染
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  /// 碰撞触发
  @override
  bool onCollision(GameComponent component, bool active) {
    bool active = true;

    /// 碰撞 Orc 不发生碰撞
    if (component is Orc) {
      print('碰撞 Orc');
      active = false;
    }
    return active;
  }

  @override
  void update(double dt) {
    if (canMove) {
      /// 发现玩家
      seePlayer(
        radiusVision: tileSize * 5,

        /// 发现
        observed: (player) {
          /// 相机跟随玩家放大
          gameRef.camera.moveToPlayerAnimated(
            zoom: 1.5,
            finish: () {},
            duration: const Duration(seconds: 1),
            curve: Curves.decelerate,
          );

          /// 跟随玩家
          followComponent(
            player,
            dt,
            closeComponent: (comp) {
              /// 抵达玩家，开始攻击
              _execAttack();
            },
          );
        },

        /// 未发现
        notObserved: () {
          /// 相机跟随玩家变为正常
          gameRef.camera.moveToPlayerAnimated(
            zoom: 1,
            finish: () {},
            duration: const Duration(seconds: 1),
            curve: Curves.decelerate,
          );

          /// 随机移动
          runRandomMovement(
            dt,
            speed: speed / 3,
            maxDistance: (tileSize * 2).toInt(),
          );
        },
      );
    }
    super.update(dt);
  }

  /// 死亡
  @override
  void die() {
    canMove = false;
    gameRef.lighting?.animateToColor(Colors.black.withOpacity(0.7));

    /// 死亡动画
    animation?.playOnce(
      SpriteSheetOrc.getDie(),
      onFinish: () {
        /// 动画完成后从父类移除
        removeFromParent();
      },
      runToTheEnd: true,
    );
    super.die();
  }

  /// 受伤触发
  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    if (!isDead) {
      /// 伤害显示
      showDamage(
        damage,
        initVelocityTop: -2,
        config: TextStyle(color: Colors.amberAccent, fontSize: tileSize / 2),
      );

      /// 受伤动画
      // _addDamageAnimation();
    }
    super.receiveDamage(attacker, damage, identify);
  }

  /// 攻击动画
  void _addAttackAnimation() {
    Future<SpriteAnimation> newAnimation;
    switch (lastDirection) {
      case Direction.left:
        newAnimation = SpriteSheetOrc.getAttackBottomLeft();
      case Direction.right:
        newAnimation = SpriteSheetOrc.getAttackBottomRight();
      case Direction.up:
        if (lastDirectionHorizontal == Direction.right) {
          newAnimation = SpriteSheetOrc.getAttackTopRight();
        } else {
          newAnimation = SpriteSheetOrc.getAttackTopLeft();
        }
      case Direction.down:
        if (lastDirectionHorizontal == Direction.right) {
          newAnimation = SpriteSheetOrc.getAttackBottomRight();
        } else {
          newAnimation = SpriteSheetOrc.getAttackBottomLeft();
        }
      case Direction.upLeft:
        newAnimation = SpriteSheetOrc.getAttackTopLeft();
      case Direction.upRight:
        newAnimation = SpriteSheetOrc.getAttackTopRight();
      case Direction.downLeft:
        newAnimation = SpriteSheetOrc.getAttackBottomLeft();
      case Direction.downRight:
        newAnimation = SpriteSheetOrc.getAttackBottomRight();
    }
    animation?.playOnce(
      newAnimation,
      runToTheEnd: true,
    );
  }

  /// 受伤动画
  // void _addDamageAnimation() {
  //   canMove = false;
  //   Future<SpriteAnimation> newAnimation;
  //   switch (lastDirection) {
  //     case Direction.left:
  //       newAnimation = SpriteSheetOrc.getDamageBottomLeft();
  //     case Direction.right:
  //       newAnimation = SpriteSheetOrc.getDamageBottomRight();
  //     case Direction.up:
  //       if (lastDirectionHorizontal == Direction.right) {
  //         newAnimation = SpriteSheetOrc.getDamageTopRight();
  //       } else {
  //         newAnimation = SpriteSheetOrc.getDamageTopLeft();
  //       }
  //     case Direction.down:
  //       if (lastDirectionHorizontal == Direction.right) {
  //         newAnimation = SpriteSheetOrc.getDamageBottomRight();
  //       } else {
  //         newAnimation = SpriteSheetOrc.getDamageBottomLeft();
  //       }
  //     case Direction.upLeft:
  //       newAnimation = SpriteSheetOrc.getDamageTopLeft();
  //     case Direction.upRight:
  //       newAnimation = SpriteSheetOrc.getDamageTopRight();
  //     case Direction.downLeft:
  //       newAnimation = SpriteSheetOrc.getDamageBottomLeft();
  //     case Direction.downRight:
  //       newAnimation = SpriteSheetOrc.getDamageBottomRight();
  //   }
  //   animation?.playOnce(
  //     newAnimation,
  //     runToTheEnd: true,
  //     onFinish: () {
  //       canMove = true;
  //     },
  //   );
  // }

  /// 攻击
  void _execAttack() {
    simpleAttackMelee(
      damage: 50 + Random().nextDouble() * 200,
      size: Vector2.all(tileSize * 1.5),
      interval: 800,
      execute: () {
        _addAttackAnimation();
      },
    );
  }
}

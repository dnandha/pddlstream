(define (domain rovers)
  (:requirements :equality :typing :durative-actions :numeric-fluents :derived-predicates :conditional-effects :disjunctive-preconditions)
	;(:types robot)
  (:constants r0 r1 ) ; - robot)
  (:predicates
    (Robot ?r)
    (Conf ?q)
    (Traj ?t)
    (Motion ?q1 ?t ?q2)
    ;(CFreeConfConf ?q1 ?q2)
    ;(CFreeTrajConf ?t1 ?q2)
    ;(CFreeTrajTraj ?t1 ?t2)
    (ConfConfCollision ?q1 ?q2)
    (TrajConfCollision ?t1 ?q2)
    (TrajTrajCollision ?t1 ?t2)

    (Safe)
    (AtConf ?r ?q)
    (OnTraj ?r ?t)
    (SafeTraj ?r ?t ?r2)
    (UnsafeConf ?r ?q)
    (UnsafeTraj ?r ?t)
  )
  (:functions
    (TrajDistance ?t)
    (Speed ?r)
    (Energy ?r)
    (RechargeRate ?r)
    (ConsumptionRate ?r)
    (BatteryCapacity ?r)
  )

  ; TODO: can use ?duration as a function
  ; (+ f1 f2), (- f1 f2), (* f1 f2), (/ f1 f2)
  (:durative-action recharge
		:parameters (?r ?q)
    :duration (= ?duration (/ (- (BatteryCapacity ?r) (Energy ?r)) (RechargeRate ?r)))
		:condition (and
			(at start (Robot ?r))
      (at start (Conf ?q))
			(at start (AtConf ?r ?q))
      (over all (AtConf ?r ?q))
			(at end (AtConf ?r ?q))
    )
    :effect (and
      (at end (increase (Energy ?r) (* (RechargeRate ?r) ?duration)))
      ; (at end (assign (Energy ?r) 1))
      ; (at end (scale-up (Energy ?r) 2))
    )
  )

  (:durative-action move
		:parameters (?r ?q1 ?t ?q2)
    ; :duration (= ?duration 1)
		; :duration (= ?duration (TrajDuration ?t))
    :duration (= ?duration (/ (TrajDistance ?t) (Speed ?r)))
		:condition (and
			(at start (Robot ?r))
      (at start (Motion ?q1 ?t ?q2))
			(at start (AtConf ?r ?q1))
      ;(at start (= 1 (Energy ?r)))

      ; The following is legal!
      ;(at start (>= 1 (Energy ?r)))
			(at start (<= (* (ConsumptionRate ?r) ?duration) (Energy ?r)))

      ;(at start (Safe))
      ;(over all (Safe))
			;(at end (Safe))

       ;(forall (?r2) (at start (SafeTraj ?r ?t ?r2)))

      ;(at start (SafeTraj ?r ?t r0))
      ;(over all (SafeTraj ?r ?t r0))
      ;(at start (SafeTraj ?r ?t r1))
      ;(over all (SafeTraj ?r ?t r1))

      (at start (not (UnsafeConf ?r ?q1)))
      (over all (not (UnsafeTraj ?r ?t)))
      (at end (not (UnsafeConf ?r ?q2)))
		)
		:effect (and
      (at start (Decrease (Energy ?r) (* (ConsumptionRate ?r) ?duration)))
			(at start (not (AtConf ?r ?q1)))
      (at start (OnTraj ?r ?t))
      (at end (not (OnTraj ?r ?t)))
			(at end (AtConf ?r ?q2))
      ; (forall (?r2 ?t2) (when (over all (OnTraj ?r2 ?t2)) (at end (not (Safe)))))
		)
	)

;  (:derived (SafeTraj ?r1 ?t1 ?r2)
;	    (and (Robot ?r1) (Traj ?t1) (Robot ?r2) (or
;            (= ?r1 ?r2)
;            (exists (?q2) (and (CFreeTrajConf ?t1 ?q2)
;                               (AtConf ?r2 ?q2)))
;            (exists (?t2) (and (CFreeTrajTraj ?t1 ?t2)
;                               (OnTraj ?r2 ?t2)))
;            )
;      )
;  )

  (:derived (UnsafeConf ?r1 ?q1)
      ; Declare failure if ever the same configuration is used
      (and (Robot ?r1) (or
        (exists (?r2 ?q2) (and (Robot ?r2) (not (= ?r1 ?r2)) (ConfConfCollision ?q1 ?q2)
                               (AtConf ?r2 ?q2)))
        (exists (?r2 ?t2) (and (Robot ?r2) (not (= ?r1 ?r2)) (TrajConfCollision ?t2 ?q1)
                               (OnTraj ?r2 ?t2)))
      ))
  )

  (:derived (UnsafeTraj ?r1 ?t1)
      (and (Robot ?r1) (or
        (exists (?r2 ?q2) (and (Robot ?r2) (not (= ?r1 ?r2)) (TrajConfCollision ?t1 ?q2)
                               (AtConf ?r2 ?q2)))
        (exists (?r2 ?t2) (and (Robot ?r2) (not (= ?r1 ?r2)) (TrajTrajCollision ?t1 ?t2)
                               (OnTraj ?r2 ?t2)))
      ))
  )
)
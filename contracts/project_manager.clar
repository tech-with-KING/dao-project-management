;; dao-project-management
;; Project management system for DAOs with milestone-based payments

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-MILESTONE (err u101))
(define-constant ERR-ALREADY-COMPLETED (err u102))
(define-constant ERR-INSUFFICIENT-VOTES (err u103))
(define-constant ERR-INVALID-PROJECT-ID (err u104))
(define-constant ERR-INVALID-MILESTONE-ID (err u105))
(define-constant ERR-INVALID-MIN-VOTES (err u106))
(define-constant MAX-PROJECT-ID u1000000)
(define-constant MAX-MILESTONE-ID u100)
(define-constant MAX-MIN-VOTES u100)

;; Data Variables
(define-data-var min-votes uint u3)
(define-data-var treasury-balance uint u0)

;; Define custom types
(define-map Projects
    { project-id: uint }
    {
        owner: principal,
        contractor: principal,
        total-milestones: uint,
        completed-milestones: uint,
        total-budget: uint,
        funds-released: uint,
        active: bool
    }
)

(define-map Milestones
    { project-id: uint, milestone-id: uint }
    {
        description: (string-ascii 256),
        amount: uint,
        completed: bool,
        votes: uint
    }
)

;; Read only functions
(define-read-only (get-project (project-id uint))
    (map-get? Projects { project-id: project-id })
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
    (map-get? Milestones { project-id: project-id, milestone-id: milestone-id })
)

;; Validation functions
(define-private (is-valid-project-id (project-id uint))
    (and 
        (> project-id u0)
        (<= project-id MAX-PROJECT-ID)
        (is-none (get-project project-id)) ;; Ensure project ID doesn't already exist
    )
)

(define-private (is-valid-milestone-id (milestone-id uint))
    (and 
        (> milestone-id u0)
        (<= milestone-id MAX-MILESTONE-ID)
    )
)

;; Public functions
(define-public (create-project (project-id uint) (contractor principal) (total-milestones uint) (total-budget uint))
    (let
        (
            (project-data {
                owner: tx-sender,
                contractor: contractor,
                total-milestones: total-milestones,
                completed-milestones: u0,
                total-budget: total-budget,
                funds-released: u0,
                active: true
            })
        )
        (begin
            (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
            (asserts! (is-valid-project-id project-id) ERR-INVALID-PROJECT-ID)
            (map-set Projects { project-id: project-id } project-data)
            (ok true)
        )
    )
)

(define-public (add-milestone (project-id uint) (milestone-id uint) (description (string-ascii 256)) (amount uint))
    (let
        (
            (project (unwrap! (get-project project-id) ERR-INVALID-MILESTONE))
            (milestone-data {
                description: description,
                amount: amount,
                completed: false,
                votes: u0
            })
        )
        (begin
            (asserts! (is-eq tx-sender (get owner project)) ERR-NOT-AUTHORIZED)
            (asserts! (is-valid-milestone-id milestone-id) ERR-INVALID-MILESTONE-ID)
            ;; Check if milestone already exists
            (asserts! (is-none (get-milestone project-id milestone-id)) ERR-INVALID-MILESTONE-ID)
            (map-set Milestones { project-id: project-id, milestone-id: milestone-id } milestone-data)
            (ok true)
        )
    )
)

(define-public (vote-milestone-completion (project-id uint) (milestone-id uint))
    (let
        (
            (milestone (unwrap! (get-milestone project-id milestone-id) ERR-INVALID-MILESTONE))
            (project (unwrap! (get-project project-id) ERR-INVALID-MILESTONE))
            (new-votes (+ (get votes milestone) u1))
        )
        (begin
            (asserts! (not (get completed milestone)) ERR-ALREADY-COMPLETED)
            (asserts! (is-valid-milestone-id milestone-id) ERR-INVALID-MILESTONE-ID)
            (map-set Milestones
                { project-id: project-id, milestone-id: milestone-id }
                (merge milestone { votes: new-votes })
            )
            (if (>= new-votes (var-get min-votes))
                (complete-milestone project-id milestone-id)
                (ok true)
            )
        )
    )
)

(define-private (complete-milestone (project-id uint) (milestone-id uint))
    (let
        (
            (milestone (unwrap! (get-milestone project-id milestone-id) ERR-INVALID-MILESTONE))
            (project (unwrap! (get-project project-id) ERR-INVALID-MILESTONE))
            (new-completed (+ (get completed-milestones project) u1))
            (new-released (+ (get funds-released project) (get amount milestone)))
        )
        (begin
            (map-set Projects
                { project-id: project-id }
                (merge project {
                    completed-milestones: new-completed,
                    funds-released: new-released
                })
            )
            (map-set Milestones
                { project-id: project-id, milestone-id: milestone-id }
                (merge milestone { completed: true })
            )
            (ok true)
        )
    )
)

;; Administrative functions
(define-public (update-min-votes (new-min-votes uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (and (> new-min-votes u0) (<= new-min-votes MAX-MIN-VOTES)) ERR-INVALID-MIN-VOTES)
        (var-set min-votes new-min-votes)
        (ok true)
    )
)
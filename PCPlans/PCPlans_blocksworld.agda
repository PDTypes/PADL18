-- this file gives a worked-out example of the Blockworld problem from PDDL literature

module PCPlans_blocksworld where

open import Relation.Binary.PropositionalEquality
open import Relation.Binary
open import Data.List
open import Data.List.Any
open import Relation.Nullary using (yes; no; Dec)
open import Level

open import Tactic.Deriving.Eq

--------------------------------------------------------
-- A robot arm assembles a tower out of 3 blocks -- a, b, c 
-- Figure 2:
--

-- Constants, or objects: a,b,c
data C : Set where
  a b c : C
-- EqC : Eq C
unquoteDecl EqC = deriveEq EqC (quote C)


-- Predicates, -- they describe properties and relations that the planner verifies
data R : Set where
  handEmpty : R
  onTable : C → R
  clear : C → R
  holding : C → R
  on : C → C → R
-- EqR : Eq R
unquoteDecl EqR = deriveEq EqR (quote R)

open import Mangle using (mangle)
{-
_≡?_ : Decidable (_≡_ {A = R})
_≡?_ x y = mangle x y 
-}

-- Instatiation of decidability of predicates to the IsDecEquivalence type
isDecidable : IsDecEquivalence {zero} {zero} (_≡_ {A = R})
isDecidable = record { isEquivalence = record {
  refl = λ {x} → refl ;
  sym = λ x → sym x ;
  trans = trans } ;
  _≟_ = mangle  }


-- We now define the possible actions that a robot can perform: 
-- Actions (Figure 7)
data Action : Set where 
  pickup_from_table_b : Action
  pickup_from_table_a : Action
  putdown_on_stack_b_c : Action
  putdown_on_stack_a_b : Action


-- Instantiation of module PCPlans
-- PCPlans is parameterised by the Action Set, Predicate Set
-- as well as a proof showing that the Predicate Set is decidable
open import PCPlans {Action} {R} {isDecidable}
open import Data.Product

--------------------------------------------------------
-- Figure 7
--

-- Example plan for Blocksworld, generated by a PDDL planner:
plan₁ : Plan
plan₁ = doAct pickup_from_table_b
        (doAct putdown_on_stack_b_c
        (doAct pickup_from_table_a
        (doAct putdown_on_stack_a_b
         halt)))
         
--------------------------------------------------------
-- Figure 8
--

-- Definition of context showing preconditions and
-- postconditions of actions
Γ₁ : Γ
Γ₁ pickup_from_table_b  =
  (atom handEmpty ∧ atom (onTable b) ∧ atom (clear b)) ↓₊ ,
  ((¬ handEmpty ∧ ¬ (onTable b) ∧ atom (holding b)) ↓₊)
Γ₁ pickup_from_table_a  =
  (atom handEmpty ∧ atom (onTable a) ∧ atom (clear a)) ↓₊ ,
  ((¬ handEmpty ∧ ¬ (onTable a) ∧ atom (holding a)) ↓₊)
Γ₁ putdown_on_stack_b_c =
  (atom (holding b) ∧ atom (clear c)) ↓₊ ,
  (¬ (holding b) ∧ ¬ (clear c) ∧ atom (on b c) ∧ atom handEmpty) ↓₊
Γ₁ putdown_on_stack_a_b =
  (atom (holding a) ∧ atom (clear b)) ↓₊ ,
  (¬ (holding a) ∧ ¬ (clear b) ∧ atom (on a b) ∧ atom handEmpty) ↓₊ 


--------------------------------------------------------
-- Figure 11
--

-- Initial State
P₀ : Form
P₀ = atom (onTable a) ∧ atom (onTable b) ∧ atom (onTable c) ∧ atom (clear a) ∧ atom (clear b) ∧ atom (clear c) ∧ atom handEmpty

-- Goal State
Q₀ : Form
Q₀ = atom (on a b) ∧ atom (on b c)

-- Derivation of plan₁ on P₀ and Q₀
Derivation : Γ₁ ⊢ plan₁ ∶ (P₀ ↓₊) ↝ (Q₀ ↓₊)
Derivation = 
  seq (atom<: (there (there (here refl)))
      (atom<: (there (there (there (there (there (here refl))))))
      (atom<: (here refl)
      ([]<: ((+ , handEmpty) ∷
             (+ , clear c) ∷
             (+ , clear b) ∷
             (+ , clear a) ∷
             (+ , onTable c) ∷ (+ , onTable b) ∷ (+ , onTable a) ∷ [])))))
      refl
  (seq (atom<: (there (there (there (here refl))))
       (atom<: (here refl)
       ([]<: ((+ , holding b) ∷
              (- , onTable b) ∷
              (- , handEmpty) ∷
              (+ , clear c) ∷
              (+ , clear b) ∷
              (+ , clear a) ∷ (+ , onTable c) ∷ (+ , onTable a) ∷ []))))
       refl
  (seq (atom<: (there (there (there (there (there (there (here refl)))))))
       (atom<: (there (there (there (there (there (there (there (there (here refl)))))))))
       (atom<: (here refl)
       ([]<: ((+ , handEmpty) ∷
              (+ , on b c) ∷
              (- , clear c) ∷
              (- , holding b) ∷
              (- , onTable b) ∷
              (+ , clear b) ∷
              (+ , clear a) ∷ (+ , onTable c) ∷ (+ , onTable a) ∷ [])))))
       refl
  (seq (atom<: (there (there (there (there (there (there (there (here refl))))))))
       (atom<: (here refl)
       ([]<: ((+ , holding a) ∷
              (- , onTable a) ∷
              (- , handEmpty) ∷
              (+ , on b c) ∷
              (- , clear c) ∷
              (- , holding b) ∷
              (- , onTable b) ∷
              (+ , clear b) ∷ (+ , clear a) ∷ (+ , onTable c) ∷ []))))
       refl
  (halt (atom<: (there (there (there (there (there (here refl))))))
        (atom<: (there (here refl))
        ([]<: ((+ , handEmpty) ∷
               (+ , on a b) ∷
               (- , clear b) ∷
               (- , holding a) ∷
               (- , onTable a) ∷
               (+ , on b c) ∷
               (- , clear c) ∷
               (- , holding b) ∷
               (- , onTable b) ∷ (+ , clear a) ∷ (+ , onTable c) ∷ [])))))))) 

---------------------------------------------------------------

{- Illustration for the Soundness Theorem:  The workings of a canonical handler. To test, evaluate the below
functions world-eval and formula-eval
  -}

wP₁ : World
wP₁ = (onTable a) ∷ (onTable b) ∷ (onTable c) ∷ (clear a) ∷ (clear b) ∷ (clear c) ∷ handEmpty ∷ []


world-eval : World
world-eval = ⟦ plan₁ ⟧ (canonical-σ Γ₁) wP₁

formula-eval : World
formula-eval = ⟦ plan₁ ⟧ (canonical-σ Γ₁) (σα (P₀ ↓[ + ] []) [])



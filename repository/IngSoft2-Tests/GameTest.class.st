Class {
	#name : #GameTest,
	#superclass : #TestCase,
	#category : #'IngSoft2-Tests'
}

{ #category : #setup }
GameTest >> fede [
	^'Fede'
]

{ #category : #setup }
GameTest >> glenn [
	^'Glenn'
]

{ #category : #setup }
GameTest >> nicky [
	^ 'Nicky'
]

{ #category : #tests }
GameTest >> testAPlayerPlaysTwiceFails [
	| board playerOne playerTwo die game |
	die := LoadedDie withValue: 6.
	playerOne := self fede.
	playerTwo := self glenn.
	board := Board withSpaces: 10 Laps: 2.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}.
	game play: playerOne.
	self should: [ game play: playerOne ] raise: TurnError
]

{ #category : #tests }
GameTest >> testAtomicBombEffect [
	| board playerOne die game |
	playerOne := self fede.
	die := LoadedDie withValue: 4.
	board := Board
		withSpaces: 2
		Laps: 3
		effects: {(AtomicBombEffect withProbability: 1)}.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 1 lap: 3)
]

{ #category : #tests }
GameTest >> testAtomicBombEffectWithAnotherPlayerInStartingPosition [
	| board playerOne die game playerTwo |
	playerOne := self fede.
	playerTwo := self glenn.
	die := LoadedDie withValue: 7.
	board := Board
		withSpaces: 5
		Laps: 2
		effects: {(AtomicBombEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 1 lap: 2).
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 1 lap: 1)
]

{ #category : #tests }
GameTest >> testCancellationCard [
	| board playerOne die game deckOfCards playerTwo cancellationCard |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck
		withCards:
			{SpeedCard new.
			CancellationCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	10
		timesRepeat: [ game play: playerOne.
			game play: playerTwo ].
	game playCard: SpeedCard new from: playerOne to: playerTwo.
	game play: playerOne.
	cancellationCard := CancellationCard new
		target: (SpeedCard new target: playerTwo).
	game playCard: cancellationCard from: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 12 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 12 lap: 1)
]

{ #category : #tests }
GameTest >> testCancellationCardWithNoPermanentCardsActive [
	| board playerOne die game deckOfCards cancellation |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	deckOfCards := Deck withCards: {CancellationCard new}.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	cancellation := CancellationCard new target: SpeedCard new.
	self
		should: [ game playCard: cancellation from: playerOne ]
		raise: MissingActiveCardEffect
]

{ #category : #tests }
GameTest >> testCancellationCardWithTwoEqualActiveEffects [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck
		withCards:
			{SpeedCard new.
			CancellationCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	10
		timesRepeat: [ game play: playerOne.
			game play: playerTwo ].
	game playCard: SpeedCard new from: playerOne to: playerTwo.
	game play: playerOne.
	game playCard: SpeedCard new from: playerTwo to: playerTwo.
	game
		playCard: (CancellationCard new target: (SpeedCard new target: playerTwo))
		from: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 13 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 12 lap: 1)
]

{ #category : #tests }
GameTest >> testCannotPlayCardThatIsNotInHand [
	| board playerOne die game deckOfCards |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	deckOfCards := Deck withCards: {NoEffectCard new}.
	board := Board withSpaces: 5 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	self
		should: [ game playCard: AccelerationCard new from: playerOne ]
		raise: MissingCardError
]

{ #category : #tests }
GameTest >> testCannotPlayPermanentCardOutOfTurn [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {AccelerationCard new}.
	board := Board withSpaces: 5 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	self
		should: [ game playCard: AccelerationCard new from: playerTwo ]
		raise: TurnError
]

{ #category : #tests }
GameTest >> testCompleteOneLap [
	| board playerOne die game|
	die := LoadedDie withValue: 6.
	playerOne := self fede.
	board := Board withSpaces:10 Laps: 2.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}.
	game play: playerOne.
	game play: playerOne.
	self assert: (game positionOf: playerOne) equals: (Locker position: 3 lap: 2).
]

{ #category : #tests }
GameTest >> testDrawCardEffect [
	| board playerOne die game deckOfCards |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	deckOfCards := Deck withCards: {NoEffectCard new}.
	board := Board
		withSpaces: 5
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	game play: playerOne.
	self assert: (game checkHandOf: playerOne) size equals: 3
]

{ #category : #tests }
GameTest >> testGameScoreBoard [
	| board playerOne playerTwo die result game |
	die := LoadedDie withValue: 6.
	playerOne := self fede.
	playerTwo := self glenn.
	board := Board withSpaces: 10 Laps: 2.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}.
	game play: playerOne.
	game play: playerTwo.
	game play: playerOne.
	result := {playerOne.
	playerTwo} asOrderedCollection.
	self assert: result equals: game scoreBoard
]

{ #category : #tests }
GameTest >> testHandOutTwoCardsInitially [
	| game board playerOne die deckOfCards |
	die := LoadedDie withValue: 5.
	playerOne := self fede.
	board := Board withSpaces: 10 Laps: 2.
	deckOfCards := Deck withCards: {NoEffectCard new}.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	self assert: (game checkHandOf: playerOne) size equals: 2
]

{ #category : #tests }
GameTest >> testMoonWalkEffect [
	| board playerOne playerTwo die game |
	playerOne := self fede.
	playerTwo := self glenn.
	die := LoadedDie withValue: 6.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(MoonWalkEffect withProbability: 1 goBack: 2)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}.
	game play: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 5 lap: 1).
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 7 lap: 1)
]

{ #category : #tests }
GameTest >> testNoEffect [
	| board playerOne die game |
	die := LoadedDie withValue: 3.
	playerOne := self fede.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(NoEffect withProbability: 1)}.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 4 lap: 1)
]

{ #category : #tests }
GameTest >> testPlayCard [
	| board playerOne die game deckOfCards |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	deckOfCards := Deck withCards: {NoEffectCard new}.
	board := Board withSpaces: 5 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	game play: playerOne.
	game playCard: NoEffectCard new from: playerOne.
	self assert: (game checkHandOf: playerOne) size equals: 1
]

{ #category : #tests }
GameTest >> testPlayCardAcceleration [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {AccelerationCard new}.
	board := Board withSpaces: 5 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game playCard: AccelerationCard new from: playerOne.
	game play: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 4 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 4 lap: 1)
]

{ #category : #tests }
GameTest >> testPlayOverloadCard [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 5.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {OverloadCard new}.
	board := Board withSpaces: 6 Laps: 2.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game playCard: OverloadCard new from: playerOne to: playerTwo.
	game play: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 4 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 6 lap: 1)
]

{ #category : #tests }
GameTest >> testPlaySpeedCard [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 2.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {SpeedCard new}.
	board := Board withSpaces: 5 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game playCard: SpeedCard new from: playerOne to: playerTwo.
	game play: playerOne.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 4 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 3 lap: 1)
]

{ #category : #tests }
GameTest >> testPlayWithSeveralCards [
	| board playerOne die game deckOfCards finalHand |
	die := LoadedDie withValue: 1.
	deckOfCards := Deck
		withCards:
			{NoEffectCard new.
			OverloadCard new}.
	playerOne := self fede.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players: {playerOne}
		cards: deckOfCards.
	90 timesRepeat: [ game play: playerOne ].
	finalHand := game checkHandOf: playerOne.
	self assert: finalHand size equals: 92.
	self
		assert: (finalHand anySatisfy: [ :aCard | aCard = NoEffectCard new ]).
	self
		assert: (finalHand anySatisfy: [ :aCard | aCard = OverloadCard new ])
]

{ #category : #tests }
GameTest >> testPlayerDoesNotCrossLastLocker [
	| board playerOne die game |
	die := LoadedDie withValue: 12.
	playerOne := self fede.
	board := Board withSpaces: 10 Laps: 1.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: board lastLocker
]

{ #category : #tests }
GameTest >> testPlayerPlays [
	| game board playerOne die |
	die := LoadedDie withValue: 5.
	playerOne := self fede.
	board := Board withSpaces: 10 Laps: 2.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 6 lap: 1)
]

{ #category : #tests }
GameTest >> testPlayerRank [
	| board playerOne playerTwo die game |
	playerOne := self fede.
	playerTwo := self glenn.
	die := LoadedDie withValue: 6.
	board := Board withSpaces: 10 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}.
	game play: playerOne.
	game play: playerTwo.
	game play: playerOne.
	self assert: (game rankOf: playerOne) equals: 1.
	self assert: (game rankOf: playerTwo) equals: 2
]

{ #category : #tests }
GameTest >> testPlayerWins [
	| board playerOne die game |
	die := LoadedDie withValue: 6.
	playerOne := self fede.
	board := Board withSpaces: 10 Laps: 1.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self assert: game hasAWinner not.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: board lastLocker.
	self assert: game hasAWinner
]

{ #category : #tests }
GameTest >> testPlayingWithTurnsWithThreePlayers [
	| board playerOne playerTwo playerThree die game |
	playerOne := self fede.
	playerTwo := self glenn.
	playerThree := self nicky.
	die := LoadedDie withValue: 6.
	board := Board withSpaces: 10 Laps: 1.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo.
			playerThree}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 7 lap: 1).
	game play: playerTwo.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 7 lap: 1).
	game play: playerThree.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 7 lap: 1).
	game play: playerOne.
	self assert: game hasAWinner
]

{ #category : #tests }
GameTest >> testRedoInstantCard [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck
		withCards:
			{RedoCard new.
			CancellationCard new.
			SpeedCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players: (Array with: playerOne with: playerTwo)
		cards: deckOfCards.
	15
		timesRepeat: [ game play: playerOne.
			game play: playerTwo ].
	game playCard: SpeedCard new from: playerOne to: playerOne.
	game playCard: SpeedCard new from: playerOne to: playerOne.
	game
		playCard: (CancellationCard new target: (SpeedCard new target: playerOne))
		from: playerTwo.
	game
		playCard: (RedoCard new target: (SpeedCard new target: playerOne))
		from: playerTwo.
	game play: playerOne.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 16 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 17 lap: 1)
]

{ #category : #tests }
GameTest >> testRedoPermanentCard [
	| board playerOne die game deckOfCards playerTwo redoCard |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck
		withCards:
			{SpeedCard new.
			RedoCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	10
		timesRepeat: [ game play: playerOne.
			game play: playerTwo ].
	game playCard: SpeedCard new from: playerOne to: playerTwo.
	game play: playerOne.
	redoCard := RedoCard new target: playerOne.
	game playCard: redoCard from: playerOne.
	game play: playerTwo.
	game play: playerOne.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 13 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 14 lap: 1)
]

{ #category : #tests }
GameTest >> testRedoPermanentCardOverload [
	| board playerOne die game deckOfCards playerTwo redoCard |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck
		withCards:
			{OverloadCard new.
			RedoCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	10
		timesRepeat: [ game play: playerOne.
			game play: playerTwo ].
	game playCard: OverloadCard new from: playerOne to: playerTwo.
	game play: playerOne.
	redoCard := RedoCard new target: playerOne.
	game playCard: redoCard from: playerOne.
	game play: playerTwo.
	game play: playerOne.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 10 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 11 lap: 1)
]

{ #category : #tests }
GameTest >> testRepeatMoonWalkEffect [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 8.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {RepeatCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(MoonWalkEffect withProbability: 1 goBack: 4)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game play: playerOne.
	game play: playerTwo.
	game playCard: (RepeatCard new target: playerOne) from: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 5 lap: 1).
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 5 lap: 1)
]

{ #category : #tests }
GameTest >> testRepeatSpeedupEffect [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {RepeatCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(SpeedUpEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game play: playerOne.
	game playCard: (RepeatCard new target: playerTwo) from: playerTwo.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 6 lap: 1).
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 5 lap: 1)
]

{ #category : #tests }
GameTest >> testSpeedUpEffect [
	| board playerOne die game |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(SpeedUpEffect withProbability: 1)}.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 6 lap: 1)
]

{ #category : #tests }
GameTest >> testTargetTwoCardAtAPlayer [
	| board playerOne die game deckOfCards playerTwo |
	die := LoadedDie withValue: 1.
	playerOne := self fede.
	playerTwo := self glenn.
	deckOfCards := Deck withCards: {SpeedCard new}.
	board := Board
		withSpaces: 100
		Laps: 1
		effects: {(DrawCardEffect withProbability: 1)}.
	game := Game
		withBoard: board
		dice: die
		players:
			{playerOne.
			playerTwo}
		cards: deckOfCards.
	game playCard: SpeedCard new from: playerOne to: playerTwo.
	game play: playerOne.
	game playCard: SpeedCard new from: playerTwo to: playerTwo.
	game play: playerTwo.
	self
		assert: (game positionOf: playerTwo)
		equals: (Locker position: 4 lap: 1).
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 2 lap: 1)
]

{ #category : #tests }
GameTest >> testWormHoleEffect [
	| board playerOne die game |
	die := LoadedDie withValue: 6.
	playerOne := self fede.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(WormHoleEffect withProbability: 1)}.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 3 lap: 1)
]

{ #category : #tests }
GameTest >> testWormHoleEffectLimitMove [
	| board playerOne die game |
	die := LoadedDie withValue: 3.
	playerOne := self fede.
	board := Board
		withSpaces: 10
		Laps: 1
		effects: {(WormHoleEffect withProbability: 1)}.
	game := Game withBoard: board dice: die players: {playerOne}.
	game play: playerOne.
	self
		assert: (game positionOf: playerOne)
		equals: (Locker position: 1 lap: 1)
]

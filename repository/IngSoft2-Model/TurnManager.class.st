Class {
	#name : #TurnManager,
	#superclass : #Object,
	#instVars : [
		'players'
	],
	#category : #'IngSoft2-Model'
}

{ #category : #'instance creation' }
TurnManager class >> organize: somePlayers [ 
	^self new initializeWithPlayers: somePlayers
]

{ #category : #turning }
TurnManager >> alreadyPlayed: aPlayer [ 
	players addLast: (players removeFirst)
]

{ #category : #initialization }
TurnManager >> initializeWithPlayers: somePlayers [ 
	players := somePlayers asOrderedCollection.
]

{ #category : #turn }
TurnManager >> isAllowedToPlay: aPlayer [
	aPlayer = players first
		ifFalse: [ TurnError signal: 'This is not the player turn'  ]
]
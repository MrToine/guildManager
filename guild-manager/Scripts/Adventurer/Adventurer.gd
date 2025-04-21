extends Node

class_name Adventurer

var id: int
var nameHero: String
var className: String
var strength: int
var magic: int
var agility: int
var faith: int
var morale: int
var traits: Array
var injured: bool = false
var price: int

func _init(id: int, nameHero: String, className: String, strength: int, magic: int, agility: int, faith: int, morale: int, traits: Array, price: int = 0):
	self.id = id
	self.nameHero = nameHero
	self.className = className
	self.strength = strength
	self.magic = magic
	self.agility = agility
	self.faith = faith
	self.morale = morale
	self.traits = traits
	self.price = price

package ru.agentlab.maia.behaviour.primitive

import ru.agentlab.maia.IBehaviourPrimitive

interface IBehaviourPrimitiveReflection extends IBehaviourPrimitive {

	def void setImplementation(Object impl)

}
package ru.agentlab.maia.messaging

interface IMessageDeliveryService {

	def void send(IMessage message)

	def void addReceiveListener(IMessageDeliveryEventListener listener)

}
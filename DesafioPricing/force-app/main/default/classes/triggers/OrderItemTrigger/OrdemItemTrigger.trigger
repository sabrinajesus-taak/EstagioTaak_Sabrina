trigger OrdemItemTrigger on OrderItem (after insert, after update, before insert, before update, before delete) {
	new OrdemItemHandler().run(); 
}
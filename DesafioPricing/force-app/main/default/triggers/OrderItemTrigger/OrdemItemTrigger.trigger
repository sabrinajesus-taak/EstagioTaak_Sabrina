trigger OrdemItemTrigger on OrderItem (before insert, before update, before delete) {
	new OrdemItemHandler().run(); 
}
pragma solidity ^0.4.21;

/**
 *  SolarCoin is an ICO built over the Ethereum Blockchain.
 	The main goal of the ICO is to build a community of users who
 	want to invest in the construction of shared photovoltaic solar plants.
 	The ICO is used for crowdfunding and management of the plant
    
    Conta recebedora: 0x29294CBC636552b197852b53CC1178c5f7CFFB1d
 */
contract SolarCoin {

	// Eventos
	event NovaUsinaCriada(uint indexed _usinaID, uint256 indexed _goal);
	event TokenTransferido(uint indexed _from, address indexed _to, uint256 indexed _value);

	// Dados dos Clientes
	struct Client {
		address addr;
		uint8 cpf;
		string nome;
		uint usina;
	}

	// Dados das Usinas
	struct Usina {
		uint ID;
		uint numClients;
		uint initialTokenAmount;
		uint meta;
		mapping (uint => Client) clients;
	}

	uint public numUsinas;	// número de Usinas realizadas
	mapping (uint => Usina) public usinas;	// Tabela Hash para encontrar dados das Usinas feitas
	mapping (address => Client) public BancoClientes;
	mapping (uint => uint) private UsinasTokens;
	mapping (address => uint256) public balances;	// Quantidade de tokens em um endereço
	uint public totalSupply;
	string public name;

	// Construtor
	constructor (uint _initialSupply, string _tokenName) public {
		balances[msg.sender] = _initialSupply;
		totalSupply = _initialSupply;
		name = _tokenName;
	}

	// Função para criar uma nova Usina
	function newUsina (uint goal, uint _meta1 , uint passwd) public returns(uint usinaID) {
		require (passwd == 1234);
		usinaID = numUsinas++;
		Usina storage u = usinas[usinaID];
		u.ID = usinaID;
		u.meta = _meta1;
		UsinasTokens[u.ID] = goal;
		u.initialTokenAmount = goal;
		balances[msg.sender] -= goal;
		emit NovaUsinaCriada(u.ID, goal);
	}
	
	// Transferir Tokens para cliente que investiu na Usina "usinaID"
	function TransferTokens (uint usinaID, address _to, uint8 cpf, string nome, uint _value, uint passwd) public {
		require (passwd == 1234);
		Usina storage u = usinas[usinaID];
		require (UsinasTokens[u.ID] >= _value);
		Client storage c = u.clients[u.numClients++];
		c.addr = _to;
		c.cpf = cpf;
		c.nome = nome;
		c.usina = usinaID;
		BancoClientes[_to] = c;
		balances[_to] += _value;
		UsinasTokens[u.ID] -= _value;
		emit TokenTransferido(UsinasTokens[u.ID],_to,_value);
	}
	
	// Verificar dinheiro recolhido 
	function balanceOfUsina (uint _usinaID) public constant returns(uint _initial, uint vendidos, bool reached, uint _numC) {
		Usina memory u = usinas[_usinaID];
		vendidos = u.initialTokenAmount - UsinasTokens[u.ID];
		_initial = u.initialTokenAmount;
		_numC = u.numClients;
		reached = false;
		if(UsinasTokens[u.ID] >= u.meta*u.initialTokenAmount) reached = true;
	}
	
	// Consultar cliente por chave pública
	function balanceOfClient (address _client) public constant returns(uint8 _cpf,uint saldo, uint uID) {
		Client memory c = BancoClientes[_client];
		uID = c.usina;
		_cpf = c.cpf;
		saldo = balances[_client];
	}
	
}

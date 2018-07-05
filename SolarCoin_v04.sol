pragma solidity ^0.4.21;

/**
 * The SolarCoin contract does this and that...
   Conta recebedora: 0x29294CBC636552b197852b53CC1178c5f7CFFB1d
 */
contract SolarCoin {

	// Eventos
	event NovaUsinaCriada(address indexed _usinaAddr, uint indexed _usinaID, uint256 indexed _goal);
	event TokenTransferido(address indexed _from, address indexed _to, uint256 indexed _value);

	// Dados dos Clientes
	struct Client {
		address addr;
		uint8 cpf;
		string nome;
		uint usina;
	}

	// Dados das Usinas
	struct Usina {
		address usinaAddr;
		uint numClients;
		uint initialTokenAmount;
		mapping (uint => Client) clients;
	}

	uint public numUsinas;	// número de Usinas realizadas
	mapping (uint => Usina) public usinas;	// Tabela Hash para encontrar dados das Usinas feitas
	mapping (uint => address) private usinasToAddr;
	mapping (address => Client) public BancoClientes;
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
	function newUsina (uint goal, string passwd) public returns(uint usinaID) {
		require (passwd == "mestre");
		usinaID = numUsinas++;
		Usina u = usinas[usinaID];
		u.usinaAddr = usinasToAddr[usinaID];
		balances[u.usinaAddr] = goal;
		u.initialTokenAmount = goal;
		balances[msg.sender] -= goal;
		emit NovaUsinaCriada(u.usinaAddr, usinaID, goal);
	}
	
	// Transferir Tokens para cliente que investiu na Usina "usinaID"
	function TransferTokens (uint usinaID, address _to, uint cpf, string nome, uint _value, string passwd) public {
		require (passwd == "mestre");
		Usina u = usinas[usinaID];
		Client c = u.clients[u.numClients++];
		c.addr = _to;
		c.cpf = cpf;
		c.nome = nome;
		c.usina = usinaID;
		BancoClientes[_to] = c;
		balances[_to] += _value;
		balances[u.usinaAddr] -= _value;
		emit TokenTransferido(usinasToAddr[usinaID],_to,_value);
	}
	
	// Verificar dinheiro recolhido 
	function balanceOfUsina (uint _usinaID) public constant returns(uint vendidos) {
		Usina u = usinas[_usinaID];
		vendidos = u.initialTokenAmount - balances[u.usinaAddr];
	}
	
	function balanceOfClient (address _client) public constant returns(uint saldo) {
		return balances[_client];
	}
	
}

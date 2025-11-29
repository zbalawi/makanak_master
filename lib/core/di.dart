
import '../data/order_repository.dart';
import '../data/auth_repository.dart';

final OrderRepository orderRepository = InMemoryOrderRepository();
final AuthRepository authRepository = InMemoryAuthRepository();

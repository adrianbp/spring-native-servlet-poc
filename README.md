# Spring Native JPA Servlet - Hexagonal Architecture POC

This project demonstrates a **Spring Boot 3.4** application with **GraalVM Native compilation** using **Hexagonal Architecture** (Clean Architecture) pattern. It includes complete CI/CD pipelines, Docker configurations, and AWS EKS deployment with monitoring.

## 🏗️ Architecture

The application follows **Hexagonal Architecture** principles:

```
Domain Layer (Business Logic)
├── model/User.java           # Core business entity
├── service/UserService.java  # Business logic implementation
└── ports/                    # Interfaces defining boundaries
    ├── inbound/UserServicePort.java   # API contracts
    └── outbound/UserRepositoryPort.java # Data access contracts

Infrastructure Layer (Technical Details)
├── adapter/inbound/web/      # REST API adapters
│   ├── controller/UserController.java
│   └── dto/                  # Data transfer objects
└── adapter/outbound/persistence/ # Database adapters
    ├── UserRepositoryAdapter.java
    ├── entity/UserJpaEntity.java
    ├── mapper/UserMapper.java
    └── repository/UserJpaRepository.java
```

## 🚀 Features

- **Spring Boot 3.4.9** with **Java 17**
- **GraalVM Native Image** compilation
- **Hexagonal Architecture** with clear separation of concerns
- **RESTful API** with CRUD operations for User entity
- **Spring Data JPA** with H2 in-memory database
- **Comprehensive testing** with unit and integration tests
- **Docker support** for both JAR and Native deployments
- **GitHub Actions CI/CD** with automated builds and deployments
- **AWS EKS deployment** with Terraform infrastructure as code
- **Prometheus + Grafana monitoring** for performance comparison

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/users` | Get all users |
| GET    | `/api/users/{id}` | Get user by ID |
| GET    | `/api/users/email/{email}` | Get user by email |
| POST   | `/api/users` | Create new user |
| PUT    | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |
| GET    | `/actuator/health` | Health check |
| GET    | `/actuator/prometheus` | Prometheus metrics |

### Example Requests

**Create User:**
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

**Get All Users:**
```bash
curl -X GET http://localhost:8080/api/users
```

## 🏃‍♂️ Running Locally

### Prerequisites
- Java 17+
- Maven 3.6+
- (Optional) GraalVM for native compilation

### Run with Maven
```bash
mvn spring-boot:run
```

### Build JAR
```bash
mvn clean package
java -jar target/native-jpa-servlet-0.0.1-SNAPSHOT.jar
```

### Build Native (requires GraalVM)
```bash
mvn clean -Pnative native:compile
./target/native-jpa-servlet
```

## 🐳 Docker

### Build Native Image
```bash
# First build the native binary
mvn clean -Pnative native:compile

# Build Docker image
docker build -f Dockerfile.native -t spring-native-app:latest .

# Run container
docker run -p 8080:8080 spring-native-app:latest
```

### Build JAR Image
```bash
# Build Docker image (includes Maven build)
docker build -f Dockerfile.jar -t spring-jar-app:latest .

# Run container
docker run -p 8080:8080 spring-jar-app:latest
```

## ☸️ Kubernetes Deployment

### Prerequisites
- AWS CLI configured
- kubectl installed
- EKS cluster (see terraform/ directory)

### Deploy Native Version
```bash
kubectl apply -f k8s/native/
```

### Deploy JAR Version
```bash
kubectl apply -f k8s/jar/
```

## 📊 Monitoring

The application includes:
- Spring Boot Actuator endpoints
- Prometheus metrics at `/actuator/prometheus`
- Health checks at `/actuator/health`
- Custom health endpoint at `/api/users/health`

### Grafana Dashboards
Access Grafana to compare metrics between native and JAR deployments:
- Memory usage
- CPU usage
- Startup time
- Response times
- Garbage collection metrics (JAR only)

## 🔄 CI/CD Workflows

Two GitHub Actions workflows are configured:

1. **Native Build** (`.github/workflows/native-build.yml`)
   - Builds native image with GraalVM
   - Creates lightweight Docker image
   - Deploys to `spring-native` namespace

2. **JAR Build** (`.github/workflows/jar-build.yml`)
   - Builds traditional JAR
   - Creates GraalVM-based Docker image
   - Deploys to `spring-jar` namespace

## 🏗️ Infrastructure as Code

Use Terraform to provision AWS EKS cluster:

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

This creates:
- EKS cluster with managed node groups
- VPC with public/private subnets
- AWS Load Balancer Controller
- Prometheus and Grafana stack

## 📈 Performance Comparison

Expected benefits of Native vs JAR:

| Metric | Native | JAR |
|--------|--------|-----|
| Startup Time | ~50ms | ~2-3s |
| Memory Usage | ~30-50MB | ~200-300MB |
| CPU Usage | Lower | Higher |
| Image Size | ~50MB | ~200MB |
| Cold Start | Faster | Slower |

## 🧪 Testing

Run unit tests:
```bash
mvn test
```

Run integration tests:
```bash
mvn verify
```

## 📝 Configuration

### Application Profiles
- `default` - Local development with H2
- `k8s` - Kubernetes deployment
- `test` - Test profile

### Environment Variables
- `SPRING_PROFILES_ACTIVE` - Active profile
- `SPRING_DATASOURCE_URL` - Database URL
- `JAVA_OPTS` - JVM options (JAR only)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

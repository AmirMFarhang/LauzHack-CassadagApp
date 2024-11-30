enum DataType {
  real,    // Actual historical data
  test,    // Test/validation data
  forecast // Predicted future data
}

class ProductData {
  final String productName;
  final double salesValue;
  final double? predictedValue; // For test data comparison
  final int month;
  final int year;
  final String description;
  final DataType dataType;

  ProductData(
      this.productName,
      this.salesValue,
      this.month,
      this.year,
      this.description,
      this.dataType, {
        this.predictedValue,
      });
}

class ChartData {
  final int month;
  final int year;
  final double value;
  final double? predictedValue;
  final String productName;
  final String description;
  final DataType dataType;

  ChartData(
      this.month,
      this.year,
      this.value,
      this.predictedValue,
      this.productName,
      this.description,
      this.dataType,
      );

  // Helper to get month index for continuous plotting
  double get monthIndex => (year - 2023) * 12 + month.toDouble();
}

class AddState {
  List<ChartData>? chartData;
  List<String> availableCountries = ['Switzerland', 'Germany'];
  String selectedCountry = 'Switzerland';
  Map<String, List<ProductData>> productsByCountry = {};

  List<int> selectedCountries = [];

  AddState() {
    initializeData();
  }


  void initializeData() {
    productsByCountry = {
      'Switzerland': [
        // Real data points (2023)
        ProductData('Product A', 145.2, 1, 2023, 'Strong Q1 performance', DataType.real),
        ProductData('Product A', 152.8, 2, 2023, 'Valentine\'s boost', DataType.real),
        ProductData('Product A', 158.4, 3, 2023, 'March campaign', DataType.real),
        ProductData('Product A', 162.1, 4, 2023, 'Spring launch', DataType.real),
        ProductData('Product A', 168.7, 5, 2023, 'May event', DataType.real),
        ProductData('Product A', 175.3, 6, 2023, 'Summer start', DataType.real),

        // Test data points with both actual and predicted values
        ProductData('Product A', 181.2, 7, 2023, 'July performance', DataType.test, predictedValue: 179.8),
        ProductData('Product A', 185.8, 8, 2023, 'August sales', DataType.test, predictedValue: 184.2),
        ProductData('Product A', 189.4, 9, 2023, 'September result', DataType.test, predictedValue: 190.5),
        ProductData('Product A', 194.7, 10, 2023, 'October growth', DataType.test, predictedValue: 195.8),
        ProductData('Product A', 201.3, 11, 2023, 'November peak', DataType.test, predictedValue: 200.1),
        ProductData('Product A', 208.9, 12, 2023, 'December closing', DataType.test, predictedValue: 207.4),
      ],
      'Germany': [
        // Real data points (2023)
        ProductData('Product A', 132.5, 1, 2023, 'New Year promotion', DataType.real),
        ProductData('Product A', 138.9, 2, 2023, 'Winter campaign', DataType.real),
        ProductData('Product A', 145.2, 3, 2023, 'Spring market entry', DataType.real),
        ProductData('Product A', 151.8, 4, 2023, 'Easter promotion', DataType.real),
        ProductData('Product A', 158.4, 5, 2023, 'May festival impact', DataType.real),
        ProductData('Product A', 164.7, 6, 2023, 'Summer launch', DataType.real),

        // Test data points with both actual and predicted values
        ProductData('Product A', 171.2, 7, 2023, 'Summer sales', DataType.test, predictedValue: 170.1),
        ProductData('Product A', 177.8, 8, 2023, 'August festival', DataType.test, predictedValue: 176.4),
        ProductData('Product A', 183.4, 9, 2023, 'Oktoberfest', DataType.test, predictedValue: 182.8),
        ProductData('Product A', 189.7, 10, 2023, 'Fall collection', DataType.test, predictedValue: 188.9),
        ProductData('Product A', 195.3, 11, 2023, 'Winter prep', DataType.test, predictedValue: 194.5),
        ProductData('Product A', 201.9, 12, 2023, 'Christmas market', DataType.test, predictedValue: 200.2),
      ],
    };

    updateChartData();
  }

  void updateChartData() {
    List<ProductData> selectedCountryData = productsByCountry[selectedCountry] ?? [];
    chartData = selectedCountryData.map((product) =>
        ChartData(
          product.month,
          product.year,
          product.salesValue,
          product.predictedValue,
          product.productName,
          product.description,
          product.dataType,
        )
    ).toList();
  }
}

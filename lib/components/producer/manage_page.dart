import 'package:flutter/material.dart';
import 'package:harvestly/components/producer/manageSection/analysisFinancesSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisMainProductsSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisReportsSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisDeliveryMethodSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisStoreViewsSection.dart';
import 'package:harvestly/components/producer/manageSection/billingSection.dart';
import 'package:harvestly/components/producer/manageSection/breadCrumbNavigator.dart';
import 'package:harvestly/components/producer/manageSection/clientsSection.dart';
import 'package:harvestly/components/producer/manageSection/basketSection.dart';
import 'package:harvestly/components/producer/manageSection/abandonedOrdersSection.dart';
import 'package:harvestly/components/producer/manageSection/deliveryMethodsSection.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/services/other/manage_section_notifier.dart';
import 'manageSection/mainPageSection.dart';
import 'manageSection/mainSectionManage.dart';
import 'manageSection/manageProductsSection.dart';

class ManagePage extends StatefulWidget {
  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final user = AuthService().currentUser;

  @override
  Widget build(BuildContext context) {
    final List<String> sectionNames = [
      "Gestão",
      "Página Principal",
      "Faturação",
      "Compras abandonadas",
      "Gestão de Stock",
      "Gestão de Preços",
      "Cabazes",
      "Clientes",
      "Análise de dados > Relatórios",
      "Análise de dados > Por Canal de Venda",
      "Análise de dados > Principais Produtos",
      "Análise de dados > Visitas à Banca",
      "Análise de dados > Finanças",
      "Canais de Venda",
      "Anúncios",
      "Destaques de Anúncios",
      "Finanças",
    ];

    final List<Widget> sections = [
      MainSectionPage(
        onClicks: {
          "mainPage":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(1),
              ),
          "billingPage":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(2),
              ),
          "ordersAbandoned":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(3),
              ),
          "manageStock":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(4),
              ),
          "managePrices":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(5),
              ),
          "baskets":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(6),
              ),
          "clients":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(7),
              ),
          "analysisReports":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(8),
              ),
          "analysisDeliveryMethod":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(9),
              ),
          "analysisMainProducts":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(10),
              ),
          "analysisStoreViews":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(11),
              ),
          "analysisFinances":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(12),
              ),
          "deliveryMethod":
              () => setState(
                () => Provider.of<ManageSectionNotifier>(
                  context,
                  listen: false,
                ).setIndex(13),
              ),
        },
      ),
      MainPageSection(),
      BillingSection(),
      AbandonedOrdersPage(),
      ManageProductsSection(),
      ManageProductsSection(),
      BasketSection(),
      ClientsSection(),
      AnalysisReportsSection(),
      AnalysisDeliveryMethodSection(),
      AnalysisMainProductsSection(),
      AnalysisStoreViewsSection(),
      AnalysisFinancesSection(),
      DeliveryMethodsSection(),
    ];

    return Consumer<ManageSectionNotifier>(
      builder: (context, manageSectionNotifier, child) {
        final int currentIndex = manageSectionNotifier.currentIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: BreadcrumbNavigation(
                items:
                    currentIndex == 0
                        ? [
                          BreadcrumbItem(
                            label: sectionNames[0],
                            onTap: () {
                              manageSectionNotifier.setIndex(0);
                            },
                          ),
                        ]
                        : [
                          BreadcrumbItem(
                            label: sectionNames[0],
                            onTap: () {
                              manageSectionNotifier.setIndex(0);
                            },
                          ),
                          BreadcrumbItem(
                            label: sectionNames[currentIndex],
                            onTap: () {},
                          ),
                        ],
              ),
            ),
            Expanded(
              child:
                  currentIndex == 0
                      ? SingleChildScrollView(child: sections[currentIndex])
                      : sections[currentIndex],
            ),
          ],
        );
      },
    );
  }
}

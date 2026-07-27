import re
import altair as alt
import xml.etree.ElementTree as ET

from typing import List, Union, Dict, Any, Optional, Tuple


class CrossPlatformMetadataExporter:
    """Export Biocentral visualizations (Altair/Custom) to SVG + metadata JSON for Flutter."""

    def __init__(self, svg_string: str, metadata: Dict[str, Any], chart: Optional[alt.Chart] = None):
        self.svg_string = svg_string
        self.metadata = metadata
        if chart is not None:
            chart_metadata = self._extract_metadata_from_altair(chart)
            self.metadata.update(chart_metadata)

    def export(self) -> Dict[str, Any]:
        """
        Export visualization to a single JSON file containing SVG and metadata.

        Returns:
            Dictionary containing both SVG string and metadata
        """
        # Parse SVG to extract interactive elements if not already present or to complement
        interactive_elements = self._parse_svg_elements(self.svg_string)

        # Merge or set points
        if 'points' not in self.metadata or not self.metadata['points']:
            self.metadata['points'] = interactive_elements
        else:
            # If we already have points (e.g. from custom metadata), we might want to keep them
            # but for now let's prefer parsed ones if they exist to ensure sync with SVG
            if interactive_elements:
                self.metadata['points'] = interactive_elements

        output = {
            'svg': self.svg_string,
            'metadata': self.metadata
        }

        return output

    @staticmethod
    def _extract_metadata_from_altair(chart: alt.Chart) -> Dict[str, Any]:
        """Extract metadata from Altair chart specification."""
        spec = chart.to_dict()

        # Extract basic chart info
        title = spec.get('title', 'Chart')
        if isinstance(title, dict):
            title = title.get('text', 'Chart')

        # Extract dimensions
        width = spec.get('width', 400)
        height = spec.get('height', 300)

        # Extract axis labels
        encoding = spec.get('encoding', {})
        x_label = CrossPlatformMetadataExporter._extract_axis_label(encoding.get('x', {}))
        y_label = CrossPlatformMetadataExporter._extract_axis_label(encoding.get('y', {}))

        # Detect chart type
        mark = spec.get('mark', {})
        if isinstance(mark, str):
            chart_type = mark
        else:
            chart_type = mark.get('type', 'unknown')

        metadata = {
            'title': title,
            'x_label': x_label,
            'y_label': y_label,
            'chart_type': chart_type,
            'dimensions': {
                'width': float(width) if isinstance(width, (int, float)) else 400.0,
                'height': float(height) if isinstance(height, (int, float)) else 300.0,
                'margin_left': 60.0,
                'margin_top': 40.0,
            },
        }

        return metadata

    @staticmethod
    def _extract_axis_label(axis_spec: Dict) -> str:
        """Extract axis label from encoding specification."""
        if 'title' in axis_spec:
            title = axis_spec['title']
            return title if isinstance(title, str) else str(title)
        if 'field' in axis_spec:
            return str(axis_spec['field'])
        return ''

    @staticmethod
    def _parse_svg_elements(svg_string: str) -> List[Dict[str, Any]]:
        """Parse SVG to extract interactive elements (bars, points, residues)."""
        try:
            # Handle potential namespaces in SVG
            root = ET.fromstring(svg_string)

            elements = []

            for element in root.iter():
                # Check for custom data attributes (used in our highlight prediction)
                # Note: ElementTree might represent data-residue as '{namespace}data-residue' or just 'data-residue'
                data_attrs = {k: v for k, v in element.attrib.items() if 'data-' in k or k == 'aria-label'}

                if not data_attrs:
                    continue

                parsed = None
                tag = element.tag.split('}')[-1]  # Remove namespace

                if tag == 'path':
                    aria_desc = element.get('aria-roledescription', '')
                    if 'bar' in aria_desc.lower():
                        parsed = CrossPlatformMetadataExporter._parse_bar_path(element)
                    else:
                        parsed = CrossPlatformMetadataExporter._parse_generic_path(element)
                elif tag == 'circle':
                    parsed = CrossPlatformMetadataExporter._parse_circle(element)
                elif tag == 'rect':
                    parsed = CrossPlatformMetadataExporter._parse_rect(element)
                elif tag == 'symbol':
                    # Sometimes Altair uses <symbol> for points
                    parsed = CrossPlatformMetadataExporter._parse_symbol(element)

                if parsed:
                    # Collect all data-* attributes and aria-label
                    data = {}
                    for k, v in element.attrib.items():
                        if k.startswith('data-'):
                            key = k[5:]  # remove 'data-'
                            data[key] = CrossPlatformMetadataExporter._try_parse_number(v)
                        elif k == 'aria-label':
                            data.update(CrossPlatformMetadataExporter._parse_aria_label(v))

                    if data:
                        parsed['data'] = data
                        elements.append(parsed)

            return elements

        except Exception as e:
            print(f"⚠️  Warning: Could not parse SVG elements: {e}")
            return []

    @staticmethod
    def _parse_bar_path(path: ET.Element) -> Optional[Dict[str, Any]]:
        """Parse a path element that represents a bar."""
        d = path.get('d', '')
        coords = CrossPlatformMetadataExporter._parse_bar_path_coords(d)
        if coords:
            x, y, width, height = coords
            return {
                'x': float(x + width / 2),
                'y': float(y + height / 2),
                'radius': 5.0,
            }
        return None

    @staticmethod
    def _parse_bar_path_coords(d: str) -> Optional[Tuple[float, float, float, float]]:
        """Parse bar path coordinates: 'M x,y h width v height h -width Z'"""
        # Improved regex to handle various spacing and signs
        m_match = re.search(r'M\s*([\d.-]+)[,\s]+([\d.-]+)', d)
        h_match = re.search(r'h\s*([\d.-]+)', d)
        v_match = re.search(r'v\s*([\d.-]+)', d)
        if m_match and h_match and v_match:
            return (float(m_match.group(1)), float(m_match.group(2)),
                    float(h_match.group(1)), float(v_match.group(1)))
        return None

    @staticmethod
    def _parse_circle(circle: ET.Element) -> Optional[Dict[str, Any]]:
        """Parse a circle element."""
        try:
            return {
                'x': float(circle.get('cx', 0)),
                'y': float(circle.get('cy', 0)),
                'radius': float(circle.get('r', 5)),
            }
        except (ValueError, TypeError):
            return None

    @staticmethod
    def _parse_rect(rect: ET.Element) -> Optional[Dict[str, Any]]:
        """Parse a rectangle element."""
        try:
            x = float(rect.get('x', 0))
            y = float(rect.get('y', 0))
            w = float(rect.get('width', 0))
            h = float(rect.get('height', 0))
            return {
                'x': x + w / 2,
                'y': y + h / 2,
                'width': w,
                'height': h,
                'radius': 5.0,
            }
        except (ValueError, TypeError):
            return None

    @staticmethod
    def _parse_generic_path(path: ET.Element) -> Optional[Dict[str, Any]]:
        """Extract first coordinate from path data."""
        d = path.get('d', '')
        # Try to find the first move command
        match = re.search(r'M\s*([\d.-]+)[,\s]+([\d.-]+)', d)
        if match:
            return {
                'x': float(match.group(1)),
                'y': float(match.group(2)),
                'radius': 5.0,
            }
        return None

    @staticmethod
    def _parse_symbol(symbol: ET.Element) -> Optional[Dict[str, Any]]:
        """Parse a symbol element (used for some points)."""
        # Symbols often use transform="translate(x,y)"
        transform = symbol.get('transform', '')
        match = re.search(r'translate\(([\d.-]+)[,\s]+([\d.-]+)\)', transform)
        if match:
            return {
                'x': float(match.group(1)),
                'y': float(match.group(2)),
                'radius': 5.0,
            }
        return None

    @staticmethod
    def _parse_aria_label(aria_label: str) -> Dict[str, Any]:
        """Parse aria-label to extract data values."""
        data = {}
        if not aria_label: return data
        parts = aria_label.split(';')
        for part in parts:
            if ':' in part:
                key, value = part.split(':', 1)
                data[key.strip()] = CrossPlatformMetadataExporter._try_parse_number(value.strip())
        return data

    @staticmethod
    def _try_parse_number(value: str) -> Union[float, int, str]:
        try:
            if '.' in value: return float(value)
            return int(value)
        except ValueError:
            return value
